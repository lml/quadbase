class CreateQuestionParts < ActiveRecord::Migration
  def self.up
    create_table :question_parts do |t|
      t.integer :multipart_question_id
      t.integer :child_question_id
      t.integer :order

      t.timestamps
    end
  end

  def self.down
    drop_table :question_parts
  end
end
