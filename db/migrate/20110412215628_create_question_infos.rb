class CreateQuestionInfos < ActiveRecord::Migration
  def self.up
    create_table :question_infos do |t|
      t.boolean :is_published
      t.integer :question_number
      t.integer :version
      t.text :notes
      t.string :question_infoable_type
      t.integer :question_infoable_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_infos
  end
end
