class RenameAssetAssetToAssetAttachment < ActiveRecord::Migration
  def self.up
    rename_column :assets, :asset_file_name, :attachment_file_name
    rename_column :assets, :asset_content_type, :attachment_content_type
    rename_column :assets, :asset_file_size, :attachment_file_size
    rename_column :assets, :asset_updated_at, :attachment_updated_at
  end

  def self.down
    rename_column :assets, :attachment_file_name, :asset_file_name
    rename_column :assets, :attachment_content_type, :asset_content_type
    rename_column :assets, :attachment_file_size, :asset_file_size
    rename_column :assets, :attachment_updated_at, :asset_updated_at
  end
end
