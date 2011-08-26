class RemoveIsMaintainerFromQuestionCollaborators < ActiveRecord::Migration
  def self.up
    remove_column :question_collaborators, :is_maintainer
  end

  def self.down
    add_column :question_collaborators, :is_maintainer, :boolean
  end
end
