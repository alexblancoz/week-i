class Professor < ActiveRecord::Base

  #associations
  has_many :course_professors

  #validations
  validates :name, length: { in: 2..100 }, presence: true
  validates :last_names, length: { in: 2..100 }, presence: true

  #selects
  scope :base, ->{ select('professors.id, professors.name, professors.last_names, professors.updated_at, professors.created_at') }
  scope :base_course_professor, ->{ select('course_professors.id AS course_professor_id') }

  #joins
  scope :with_course_professors, ->{ joins('INNER JOIN course_professors ON course_professors.professor_id = professors.id') }

  #wheres
  scope :filter_by_course, ->(course_id){ where('course_professors.course_id = ?', course_id) }

end
