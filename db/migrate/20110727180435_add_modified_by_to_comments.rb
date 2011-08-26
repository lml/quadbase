class AddModifiedByToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :modified_by, :integer
  end

  def self.down
    remove_column :comments, :modified_by
  end
end
