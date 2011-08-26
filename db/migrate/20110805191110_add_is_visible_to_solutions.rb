class AddIsVisibleToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :is_visible, :boolean
  end

  def self.down
    remove_column :solutions, :is_visible
  end
end
