class CreateProfessors < ActiveRecord::Migration
  def change
    create_table :professors do |t|
      t.string :name
      t.string :last_names

      t.timestamps
    end
  end
end
