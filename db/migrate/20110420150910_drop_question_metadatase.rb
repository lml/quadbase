class DropQuestionMetadatase < ActiveRecord::Migration
  def self.up
    drop_table :question_metadatas
  end

  def self.down
  end
end
