class CreateCourseProfessors < ActiveRecord::Migration
  def change
    create_table :course_professors do |t|
      t.integer :professor_id, null: false
      t.integer :course_id, null: false

      t.timestamps
    end
  end
end
