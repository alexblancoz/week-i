class Course < ActiveRecord::Base
  #Associations
  has_many :course_professors

  #Validations
  validates :name, length: { in: 2..150 }, presence: true
  validates :key, length: { in: 2..10 }, presence: true
  validates :semester, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, presence: true

  #selects
  scope :base, ->{ select('DISTINCT courses.id, courses.name, courses.key, courses.semester, courses.updated_at, courses.created_at') }
  scope :base_professors, ->{ select('professors.name AS professor_name, professors.last_names AS professor_last_names') }
  scope :base_course_professor_users, ->{ select('course_professor_users.id AS course_professor_user_id') }

  #joins
  scope :with_course_professors, ->{ joins('INNER JOIN course_professors ON course_professors.course_id = courses.id') }
  scope :with_professors, ->{ joins('INNER JOIN professors ON course_professors.professor_id = professors.id') }
  scope :with_course_professor_users, ->(user_id){ joins('LEFT JOIN course_professor_users ON course_professor_users.course_professor_id = course_professors.id AND course_professor_users.user_id = ' + sanitize(user_id)) }

  #wheres
  scope :filter_by_id, ->(course_id){ where('courses.id = ?', course_id) }
  scope :filter_by_user, ->(user_id){ where('course_professor_users.user_id = ?', user_id) }
  scope :filter_by_no_user, ->{ where('course_professor_users.user_id IS NULL') }

  #group
  scope :group_by_user, ->{ group('course_professor_users.user_id, courses.id') }

  #methods
  def professors
    @professors ||= Professor.base.with_course_professors.filter_by_course(self.id)
  end

end