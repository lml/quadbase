class AddDescriptionToQuestionAssets < ActiveRecord::Migration
  def self.up
    add_column :question_assets, :description, :text
  end

  def self.down
    remove_column :question_assets, :description
  end
end
