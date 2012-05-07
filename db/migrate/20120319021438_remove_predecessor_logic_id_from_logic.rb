class RemovePredecessorLogicIdFromLogic < ActiveRecord::Migration
  def self.up
    remove_column :logics, :predecessor_logic_id
  end

  def self.down
    add_column :logics, :predecessor_logic_id, :integer
  end
end
