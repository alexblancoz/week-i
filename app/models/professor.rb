class Professor < ActiveRecord::Base

  #associations
  has_many :course_professors

  #validations
  validates :name, length: { in: 2..100 }, presence: true
  validates :last_names, length: { in: 2..150 }, presence: true

  #selects
  scope :base, ->{ select('DISTINCT professors.id, professors.name, professors.last_names, professors.updated_at, professors.created_at') }
  scope :base_course_professors, ->{ select('course_professors.id AS course_professor_id') }
  scope :base_course_professor_users, ->{ select('course_professor_users.id AS course_professor_user_id, course_professor_users.user_id AS course_professor_user_user_id') }
  scope :base_courses, -> { select('courses.id AS course_id, courses.key AS course_key, courses.name AS course_name') }

  #joins
  scope :with_course_professors, ->{ joins('INNER JOIN course_professors ON course_professors.professor_id = professors.id') }
  scope :with_course_professor_users, ->{ joins('INNER JOIN course_professor_users ON course_professor_users.course_professor_id = course_professors.id') }
  scope :with_courses, -> { joins('INNER JOIN courses ON courses.id = course_professors.course_id') }

  #wheres
  scope :filter_by_course, ->(course_id){ where('course_professors.course_id = ?', course_id) }
  scope :filter_by_id, ->(id){ where('professors.id = ?', id) }

end
