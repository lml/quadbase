class AddChangesSolutionToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :changes_solution, :boolean
  end

  def self.down
    remove_column :questions, :changes_solution
  end
end
