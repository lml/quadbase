class CreateQuestionLists < ActiveRecord::Migration
  def change
    create_table :question_lists do |t|
      t.string :name
      t.boolean :public

      t.timestamps
    end
  end
  
  def self.down
    drop_table :question_lists
  end
end
