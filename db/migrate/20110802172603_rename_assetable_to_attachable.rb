class RenameAssetableToAttachable < ActiveRecord::Migration
  def self.up
    rename_column :assetable_assets, :assetable_id, :attachable_id
    rename_column :assetable_assets, :assetable_type, :attachable_type
    rename_table :assetable_assets, :attachable_assets
  end

  def self.down
    rename_table :attachable_assets, :assetable_assets
    rename_column :assetable_assets, :attachable_type, :assetable_type
    rename_column :assetable_assets, :attachable_id, :assetable_id
  end
end
