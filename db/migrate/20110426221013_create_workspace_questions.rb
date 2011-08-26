class CreateWorkspaceQuestions < ActiveRecord::Migration
  def self.up
    create_table :workspace_questions do |t|
      t.integer :workspace_id
      t.integer :question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workspace_questions
  end
end
