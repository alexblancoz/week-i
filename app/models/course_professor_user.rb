class CourseProfessorUser < ActiveRecord::Base

  #associations
  belongs_to :user
  belongs_to :course_professor

  validates :user_id, numericality: { only_integer: true }, uniqueness: { scope: :course_professor_id }, presence: true
  validates :course_professor_id, numericality: { only_integer: true }, presence: true
  validate :no_duplicate_course

  #selects
  scope :base, ->{ select('course_professor_users.id, course_professor_users.user_id, course_professor_users.course_professor_id, course_professor_users.updated_at, course_professor_users.created_at') }

  #wheres
  scope :filter_by_id, ->(id){ where('course_professor_users.id = ?', id) }

  #methods

  protected

  def no_duplicate_course
    course_id = course_professor.course.id
    if CourseProfessor.filter_by_user(self.user_id).filter_by_course(course_id).first > 0
      errors.add(:course_professor_id, I18n.translate('errors.messages.accepted'))
    end
  end

end
