class CreateQuestionDerivations < ActiveRecord::Migration
  def self.up
    create_table :question_derivations do |t|
      t.integer :derived_question_id
      t.integer :source_question_id
      t.integer :deriver_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_derivations
  end
end
