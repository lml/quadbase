class CreateQuestionDependencyPairs < ActiveRecord::Migration
  def self.up
    create_table :question_dependency_pairs do |t|
      t.integer :prerequisite_id
      t.integer :dependent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_dependency_pairs
  end
end
