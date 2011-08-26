class MakeChangesSolutionDefaultToFalse < ActiveRecord::Migration
  def self.up
    change_column_default :questions, :changes_solution, false
  end

  def self.down
    change_column_default :questions, :changes_solution, nil
  end
end
