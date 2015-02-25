class CreateCourseProfessorUsers < ActiveRecord::Migration
  def change
    create_table :course_professor_users do |t|
      t.integer :user_id
      t.integer :course_professor_id

      t.timestamps
    end
  end
end
