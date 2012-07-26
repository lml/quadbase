class CreateQuestionListQuestions < ActiveRecord::Migration
  def change
    create_table :question_list_questions do |t|
      t.integer :question_list_id
      t.integer :question_id
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :question_lists
  end
end
