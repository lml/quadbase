class AddIsPublicToLists < ActiveRecord::Migration
  def change
    add_column :lists, :is_public, :boolean, :default => false
  end
end
