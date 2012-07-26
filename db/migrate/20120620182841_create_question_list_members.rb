class CreateQuestionListMembers < ActiveRecord::Migration
  def change
    create_table :question_list_members do |t|
      t.integer :question_list_id
      t.integer :user_id
      t.boolean :is_default

      t.timestamps
    end
  end
  
  def self.down
    drop_table :question_lists
  end
end
