class CreateQuestionAssets < ActiveRecord::Migration
  def self.up
    create_table :question_assets do |t|
      t.integer :question_id
      t.integer :asset_id
      t.string :local_name

      t.timestamps
    end
  end

  def self.down
    drop_table :question_assets
  end
end
