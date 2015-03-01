class User < ActiveRecord::Base

  #concerns
  include Authenticable
  include Regex

  #modules
  module Identity
    ADMINISTRATOR = 0
    USER = 1
    TEACHER = 2
    LIST = {
        ADMINISTRATOR => {
            dashboard: [
                {
                    label: 'Grupos',
                    link: 'groups/list',
                    icon: 'fa-users'
                },
                {
                    label: 'Materias',
                    link: 'courses/list',
                    icon: 'fa-book'
                },
                {
                    label: 'Profesores',
                    link: 'professors/list',
                    icon: 'fa-graduation-cap'
                },
            ]
        },
        USER => {
            dashboard: [
                {
                    label: 'Grupos',
                    link: 'groups/list',
                    icon: 'fa-users'
                },
                {
                    label: 'Materias',
                    link: 'courses/list',
                    icon: 'fa-book'
                }
            ]
        },
        TEACHER => {
            dashboard: [
                {
                    label: 'Grupos',
                    link: 'groups/list',
                    icon: 'fa-users'
                },
                {
                    label: 'Materias',
                    link: 'courses/list',
                    icon: 'fa-book'
                }
            ]         
        }
    }

    def self.keys
      @@keys ||= LIST.keys
    end
  end

  module Major
    ITC = 0
    INT = 1
    LIST = {
        ITC => {
            name: 'ITC'
        },
        INT => {
            name: 'INT'
        }
    }

    def self.keys
      @@keys ||= LIST.keys
    end
    def self.object_values
      @@object_values ||= LIST.map{ |key, value| { key: key, name: value[:name]} }
    end
  end

  #associations
  has_many :received_scores, class_name: 'Score', :foreign_key => :user_id
  has_many :given_scores, class_name: 'Score', :foreign_key => :judge_id
  has_many :course_professor_users
  has_many :group_users

  #validations
  validates :name, length: { in: 2..100 }, presence: true
  validates :last_names, length: { in: 2..100 }, presence: true
  validates :enrollment, length: { in: 2..9 }, uniqueness: true, presence: true
  validates :major, presence: true
  validates :semester, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, presence: true

  before_save :assert_active, :if => :new_record?

  #selects
  scope :base, ->{ select('users.id, users.name, users.last_names, users.enrollment, users.major, users.semester, users.updated_at, users.created_at') }
  scope :base_group_users, ->{ select('group_users.status') }

  #joins
  scope :with_group_users, ->{ joins('INNER JOIN group_users ON group_users.user_id = users.id') }
  scope :with_groups, ->{ joins('INNER JOIN groups ON group_users.group_id = groups.id') }

  #wheres
  scope :filter_by_group, ->(group_id){ where('group_users.group_id = ?', group_id) }
  scope :filter_by_status, ->(status){ where('group_users.status = ?', status) }

  protected

  def assert_active
    self.active = true
  end

end