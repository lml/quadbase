class AddEmbargoUntilToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :embargo_until, :datetime, :default => Time.at(0)
  end
end
