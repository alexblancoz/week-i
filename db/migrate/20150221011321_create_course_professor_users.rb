class CreateCourseProfessorUsers < ActiveRecord::Migration
  def change
    create_table :course_professor_users do |t|
      t.integer :user_id, null: false
      t.integer :course_professor_id, null: false

      t.timestamps
    end
  end
end
