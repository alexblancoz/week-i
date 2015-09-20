class AddReferences < ActiveRecord::Migration
  def change
    add_foreign_key :groups, :users, column: :owner_id

    add_foreign_key :scores, :users, column: :user_id
    add_foreign_key :scores, :groups, column: :group_id

    add_foreign_key :course_professors, :courses, column: :course_id
    add_foreign_key :course_professors, :professors, column: :professor_id

    add_foreign_key :course_professor_users, :users, column: :user_id
    add_foreign_key :course_professor_users, :course_professors, column: :course_professor_id
  end
end
