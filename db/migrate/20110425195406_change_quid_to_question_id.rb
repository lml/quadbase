class ChangeQuidToQuestionId < ActiveRecord::Migration
  def self.up
    rename_column :answer_choices, :simple_question_id, :question_id
    rename_column :question_roles, :quid_id, :question_id
  end

  def self.down
    rename_column :answer_choices, :question_id, :simple_question_id
    rename_column :question_roles, :question_id, :quid_id
  end
end
