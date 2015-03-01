class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.float :amount
      t.string :observations, limit: 512
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
  end
end
