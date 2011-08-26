class RenameQuestionAssetsToAssetableAssets < ActiveRecord::Migration
  def self.up
    rename_column :question_assets, :question_id, :assetable_id
    rename_table :question_assets, :assetable_assets
  end

  def self.down
    rename_table :assetable_assets, :question_assets
    rename_column :question_assets, :assetable_id, :question_id
  end
end
