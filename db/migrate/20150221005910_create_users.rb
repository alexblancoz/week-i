class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, limit: 50, null: false
      t.string :last_names, limit: 60, null: false
      t.string :enrollment, limit: 60, null: false
      t.integer :major, limit: 3, null: false
      t.integer :campus, null: false
      t.string :hashed_password, limit: 128, null: false
      t.integer :identity, null: false
      t.boolean :active, null: false
      t.boolean :verified, null: false

      t.timestamps null: false
    end
  end
end
