class AddIsDefaultToLicenses < ActiveRecord::Migration
  def self.up
    add_column :licenses, :is_default, :boolean
  end

  def self.down
    remove_column :licenses, :is_default
  end
end
