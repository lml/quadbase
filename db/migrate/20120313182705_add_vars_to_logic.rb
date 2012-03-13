class AddVarsToLogic < ActiveRecord::Migration
  def self.up
    add_column :logics, :predecessor_logic_id, :integer
    add_column :logics, :cached_code, :text
  end

  def self.down
    remove_column :logics, :cached_code
    remove_column :logics, :predecessor_logic_id
  end
end
