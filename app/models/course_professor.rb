class CourseProfessor < ActiveRecord::Base

  #associations
  belongs_to :professor
  belongs_to :course
  has_many :course_professor_users

  #validations
  validates :professor_id, :course_id, presence: true
  validates :course_id, numericality: { only_integer: true }
  validates :professor_id, numericality: { only_integer: true }, uniqueness: { scope: :course_id }

  #selects
  scope :base, ->{ select('course_professors.id, course_professors.professor_id, course_professors.course_id, course_professors.updated_at, course_professors.created_at') }

  #joins

  scope :with_course_professor_users, ->{ joins('INNER JOIN course_professor_users ON course_professor_users.course_professor_id = course_professors.id') }

  #wheres
  scope :filter_by_id, ->(id){ where('course_professors.id = ?', id) }
  scope :filter_by_course, ->(course_id){ where('course_professors.course_id = ?', course_id) }
  scope :filter_by_professor, ->(professor_id){ where('course_professors.professor_id = ?', professor_id) }
  scope :filter_by_user, ->(user_id){ where('course_professor_users.user_id = ?', user_id) }
  
end
