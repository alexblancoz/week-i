class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, limit: 50
      t.string :key, limit: 8
      t.integer :semester

      t.timestamps
    end
  end
end
