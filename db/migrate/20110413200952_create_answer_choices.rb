class CreateAnswerChoices < ActiveRecord::Migration
  def self.up
    create_table :answer_choices do |t|
      t.integer :simple_question_id
      t.text :content
      t.decimal :credit

      t.timestamps
    end
  end

  def self.down
    drop_table :answer_choices
  end
end
