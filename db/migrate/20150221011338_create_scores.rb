class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :innovation_score
      t.integer :creativity_score
      t.integer :functionality_score
      t.integer :business_model_score
      t.integer :modeling_tools_score
      t.string :observations, limit: 512
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
  end
end
