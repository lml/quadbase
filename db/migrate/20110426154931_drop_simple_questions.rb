class DropSimpleQuestions < ActiveRecord::Migration
  def self.up
    drop_table :simple_questions
    drop_table :quids
  end

  def self.down
  end
end
