class DropMistakes < ActiveRecord::Migration
  def self.up
    drop_table :question_infos
    remove_column :simple_questions, :owner_id
  end

  def self.down
  end
end
