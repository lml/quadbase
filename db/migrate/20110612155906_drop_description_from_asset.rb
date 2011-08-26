class DropDescriptionFromAsset < ActiveRecord::Migration
  def self.up
    remove_column :assets, :description
  end

  def self.down
    add_column :assets, :description, :text
  end
end
