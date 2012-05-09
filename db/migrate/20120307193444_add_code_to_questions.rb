class AddCodeToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :code, :text
    add_column :questions, :variables, :string
  end

  def self.down
    remove_column :questions, :variables
    remove_column :questions, :code
  end
end
