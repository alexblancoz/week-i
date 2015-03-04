class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, limit: 150, null: false
      t.string :key, limit: 10, null: false
      t.integer :semester

      t.timestamps
    end
  end
end
