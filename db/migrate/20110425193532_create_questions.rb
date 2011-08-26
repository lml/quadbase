class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :number
      t.integer :version
      t.string :question_type
      t.text :content
      t.integer :question_setup_id

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
