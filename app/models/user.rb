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
                {
                    label: 'Usuarios',
                    link: 'users/list',
                    icon: 'fa-user'
                }
            ],
            name: 'Administrador'
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
            ],
            name: 'Alumno'
        },
        TEACHER => {
            dashboard: [
                {
                    label: 'Calificaciones',
                    link: 'scores/list',
                    icon: 'fa-star-half-o'
                }
              ],
            name: 'Profesor'
        }
    }

    def self.keys
      @@keys ||= LIST.keys
    end

    def self.object_values
      @@object_values ||= ->{
        hash = {}
        LIST.each do |key, value|
          hash[key] = value[:name]
        end
        hash
      }.call
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
      @@object_values ||= ->{
        hash = {}
        LIST.each do |key, value|
          hash[key] = value[:name]
        end
        hash
      }.call
    end
  end

  module Campus
    CSF = 0
    CEM = 1
    CCM = 2
    LIST = {
        CSF => {
            name: 'CSF'
        },
        CEM => {
            name: 'CEM'
        },
        CCM => {
            name: 'CCM'
        }
    }

    def self.keys
      @@keys ||= LIST.keys
    end

    def self.object_values
      @@object_values ||= ->{
        hash = {}
        LIST.each do |key, value|
          hash[key] = value[:name]
        end
        hash
      }.call
    end
  end

  #associations
  has_many :scores
  has_many :course_professor_users
  has_many :group_users

  #validations
  validates :name, length: { in: 2..100 }, presence: true
  validates :last_names, length: { in: 2..100 }, presence: true
  validates :major, presence: true
  validates :campus, numericality: { only_integer: true }, inclusion: { in: Campus.keys }, presence: true
  validates :enrollment, uniqueness: true, presence: true
  validate :validate_enrollment

  before_save :assert_active, :if => :new_record?
  before_save :assert_verified, :if => :new_record?
  before_save :assert_identity, :if => :new_record?
  before_save :sanitize_enrollment, :if => :new_record?

  after_save :send_verification_email

  #selects
  scope :base, -> { select('users.id, users.name, users.last_names, users.enrollment, users.major, users.campus, users.active, users.hashed_password, users.verified, users.updated_at, users.created_at') }
  scope :base_group_users, -> { select('group_users.status') }

  #joins
  scope :with_group_users, -> { joins('INNER JOIN group_users ON group_users.user_id = users.id') }
  scope :with_groups, -> { joins('INNER JOIN groups ON group_users.group_id = groups.id') }

  #wheres
  scope :filter_by_group, ->(group_id) { where('group_users.group_id = ?', group_id) }
  scope :filter_by_status, ->(status) { where('group_users.status = ?', status) }
  scope :filter_by_enrollment, ->(enrollment) { where('users.enrollment = ?', enrollment) }

  #methods

  protected

  def assert_active
    self.active = true
  end

  def assert_identity
    if self.enrollment.upcase.include?('A')
      self.identity = Identity::USER
    else
      self.identity = Identity::TEACHER
    end
  end

  def assert_verified
    self.verified = false
    true
  end

  def sanitize_enrollment
    self.enrollment = self.enrollment.upcase if self.enrollment.upcase.include?('A')
  end

  def validate_enrollment
    if self.enrollment and self.enrollment.upcase.include?('A')
      errors.add(:enrollment, I18n.translate('errors.messages.wrong_length', count: 9)) if self.enrollment.size != 9
    end
  end

  def send_verification_email
    unless self.verified
      mail = UserMailer.validate_user(self)
      mail.deliver!
    end
  end

end