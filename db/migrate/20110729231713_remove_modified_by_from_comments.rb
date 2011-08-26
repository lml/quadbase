class RemoveModifiedByFromComments < ActiveRecord::Migration
  def self.up
    remove_column :comments, :modified_by
  end

  def self.down
    add_column :comments, :modified_by, :integer
  end
end
