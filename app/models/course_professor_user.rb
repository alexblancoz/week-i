class CourseProfessorUser < ActiveRecord::Base

  #associations
  belongs_to :user
  belongs_to :course_professor

  #selects
  scope :base, ->{ select('course_professor_users.id, course_professor_users.user_id, course_professor_users.course_professor_id, course_professor_users.updated_at, course_professor_users.created_at') }

  #wheres
  scope :filter_by_id, ->(id){ where('course_professor_users.id = ?', id) }

end
