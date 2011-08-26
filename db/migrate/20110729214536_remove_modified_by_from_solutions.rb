class RemoveModifiedByFromSolutions < ActiveRecord::Migration
  def self.up
    remove_column :solutions, :modified_by
  end

  def self.down
    add_column :solutions, :modified_by, :integer
  end
end
