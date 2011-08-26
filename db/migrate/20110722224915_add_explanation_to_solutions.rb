class AddExplanationToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :explanation, :text
  end

  def self.down
    remove_column :solutions, :explanation
  end
end
