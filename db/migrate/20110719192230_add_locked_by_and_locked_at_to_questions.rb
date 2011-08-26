class AddLockedByAndLockedAtToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :locked_by, :integer, :default => -1
    add_column :questions, :locked_at, :datetime
  end

  def self.down
    remove_column :questions, :locked_at
    remove_column :questions, :locked_by
  end
end
