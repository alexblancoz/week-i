class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :innovation_score, null: false
      t.integer :creativity_score, null: false
      t.integer :functionality_score, null: false
      t.integer :business_model_score, null: false
      t.integer :modeling_tools_score, null: false
      t.string :observations, limit: 512
      t.integer :user_id, null: false
      t.integer :group_id, null: false

      t.timestamps
    end
  end
end
