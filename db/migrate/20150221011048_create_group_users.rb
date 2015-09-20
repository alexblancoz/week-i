class CreateGroupUsers < ActiveRecord::Migration
  def change
    create_table :group_users do |t|
      t.integer :status, null: false
      t.integer :group_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
