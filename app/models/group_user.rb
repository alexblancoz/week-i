class GroupUser < ActiveRecord::Base

  #modules
  module Status
    REQUEST = 0
    MEMBER = 1
    LIST = {
        REQUEST => {},
        MEMBER => {}
    }
    def self.keys
      @@keys ||= LIST.keys
    end
  end

  #associations
  belongs_to :group
  belongs_to :user

  #validations
  validates :user_id, :group_id, presence: true
  validates :user_id, numericality: { only_integer: true }, uniqueness: true
  validates :group_id, numericality: { only_integer: true }

  #selects
  scope :base, ->{ select('group_users.id, group_users.status, group_users.user_id, group_users.group_id, group_users.updated_at, group_users.created_at') }

  #wheres
  scope :filter_by_id, ->(id){ where('group_users.id = ?', id) }
  scope :filter_by_status, ->(status){ where('group_users.status = ?', status) }
  scope :filter_by_user, ->(user_id){ where('group_users.user_id = ?', user_id) }

  #callbacks
  before_save :assert_status, :if => :new_record?
  after_save :increase_group_count
  after_destroy :decrease_group_count

  protected

  def assert_status
    self.status = Status::REQUEST
  end

  def increase_group_count
    if self.status == Status::MEMBER
      group.member_count += 1
      group.save
    end
  end

  def decrease_group_count
    if self.status == Status::MEMBER
      group.member_count -= 1
      group.save
    end
  end

end
