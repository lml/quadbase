class RedoQuestionDependencyPairs < ActiveRecord::Migration
  def self.up
    drop_table :question_dependency_pairs
    drop_table :question_support_pairs
    
    create_table :question_dependency_pairs do |t|
      t.integer :independent_question_id
      t.integer :dependent_question_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :question_dependency_pairs
  end
end
