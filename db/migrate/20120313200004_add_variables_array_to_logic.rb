class AddVariablesArrayToLogic < ActiveRecord::Migration
  def self.up
    add_column :logics, :variables_array, :string
  end

  def self.down
    remove_column :logics, :variables_array
  end
end
