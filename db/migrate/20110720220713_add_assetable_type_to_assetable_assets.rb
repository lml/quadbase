class AddAssetableTypeToAssetableAssets < ActiveRecord::Migration
  def self.up
    add_column :assetable_assets, :assetable_type, :string
  end

  def self.down
    remove_column :assetable_assets, :assetable_type
  end
end
