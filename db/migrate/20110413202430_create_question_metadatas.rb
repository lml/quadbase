class CreateQuestionMetadatas < ActiveRecord::Migration
  def self.up
    create_table :question_metadatas do |t|
      t.integer :quid_id
      t.boolean :is_published
      t.integer :private_comment_thread_id
      t.integer :public_comment_thread_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_metadatas
  end
end
