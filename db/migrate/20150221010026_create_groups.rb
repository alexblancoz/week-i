class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, limit: 150, null: false
      t.integer :owner_id, null: false
      t.integer :member_count, null: false
      t.timestamps null: false
    end
  end
end
