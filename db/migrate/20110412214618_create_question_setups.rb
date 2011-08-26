class CreateQuestionSetups < ActiveRecord::Migration
  def self.up
    create_table :question_setups do |t|
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :question_setups
  end
end
