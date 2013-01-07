class AddEmbargoTimeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :embargo_time, :integer, :default => 0
  end
end
