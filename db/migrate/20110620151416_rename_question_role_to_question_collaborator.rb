class RenameQuestionRoleToQuestionCollaborator < ActiveRecord::Migration
  def self.up
    rename_table :question_roles, :question_collaborators
    rename_column :question_role_requests, :question_role_id, :question_collaborator_id
  end

  def self.down
    rename_table :question_collaborators, :question_roles
    rename_column :question_role_requests, :question_collaborator_id, :question_role_id
  end
end
