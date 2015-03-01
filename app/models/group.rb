class Group < ActiveRecord::Base

  #associations
  has_many :group_users
  has_many :scores
  
  #validations
  validates :name, length: { in: 2..100 }, presence: true
  validates :owner_id, presence: true
  validate :no_groups, :if => :new_record?

  before_save :assert_member_count, :if => :new_record?

  #selects
  scope :base, ->{ select('groups.id, groups.name, groups.owner_id, groups.member_count, groups.updated_at, groups.created_at') }
  scope :base_count, ->{ select('COUNT(groups.id) AS count') }
  scope :base_users, ->{ select('users.name AS user_name, users.last_names AS user_last_names') }
  scope :base_group_users, ->{ select('group_users.status') }

  #joins
  scope :with_users, ->{ joins('INNER JOIN users ON users.id = groups.owner_id') }
  scope :with_group_users, ->(user_id){ joins('LEFT JOIN group_users ON group_users.group_id = groups.id AND group_users.user_id = ' + sanitize(user_id)) }
  scope :with_scores, ->(user_id){ joins('LEFT JOIN scores ON scores.group_id = groups.id AND scores.user_id = ' + sanitize(user_id)) }

  #wheres
  scope :filter_by_id, ->(id){ where('groups.id = ?', id) }
  scope :filter_by_user, ->(user_id){ where('groups.owner_id = ?', user_id) }

  #methods

  def members
    @members ||= User.base.base_group_users.with_group_users.filter_by_group(self.id)
  end

  protected

  def no_groups
    if self.class.base_count.filter_by_user(self.owner_id)[0][:count] > 0
      errors[:name] << 'No puedes tener más de un grupo'
    end
  end

  def assert_member_count
    self.member_count = 1
  end
  
end
