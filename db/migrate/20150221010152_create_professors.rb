class CreateProfessors < ActiveRecord::Migration
  def change
    create_table :professors do |t|
      t.string :name, limit: 100, null: false
      t.string :last_names, limit: 150, null: false

      t.timestamps
    end
  end
end
