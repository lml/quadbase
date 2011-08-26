class CreateQuestionSupportPairs < ActiveRecord::Migration
  def self.up
    create_table :question_support_pairs do |t|
      t.integer :supporting_question_id
      t.integer :supported_question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_support_pairs
  end
end
