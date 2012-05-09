class AddAlwaysRequiredToLogicLibrary < ActiveRecord::Migration
  def self.up
    add_column :logic_libraries, :always_required, :boolean
  end

  def self.down
    remove_column :logic_libraries, :always_required
  end
end
