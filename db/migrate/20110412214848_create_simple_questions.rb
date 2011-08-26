class CreateSimpleQuestions < ActiveRecord::Migration
  def self.up
    create_table :simple_questions do |t|
      t.text :content
      t.integer :question_setup_id
      t.integer :owner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :simple_questions
  end
end
