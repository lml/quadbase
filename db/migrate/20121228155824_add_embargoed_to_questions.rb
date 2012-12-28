class AddEmbargoedToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :embargoed, :boolean, :default => false
  end
end
