class AddEmbargoedToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :embargoed, :boolean, :default => false
    add_column :questions, :embargo_time, :integer, :default => nil
  end
end
