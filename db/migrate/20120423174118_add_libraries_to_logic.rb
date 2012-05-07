class AddLibrariesToLogic < ActiveRecord::Migration
  def self.up
    add_column :logics, :required_logic_library_version_ids, :string
  end

  def self.down
    remove_column :logics, :required_logic_library_version_ids
  end
end
