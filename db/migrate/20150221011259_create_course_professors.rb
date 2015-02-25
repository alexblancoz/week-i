class CreateCourseProfessors < ActiveRecord::Migration
  def change
    create_table :course_professors do |t|
      t.integer :professor_id
      t.integer :course_id

      t.timestamps
    end
  end
end
