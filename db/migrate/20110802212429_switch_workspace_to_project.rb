class SwitchWorkspaceToProject < ActiveRecord::Migration
  def self.up
    rename_column :user_profiles, :workspace_member_email, :project_member_email
    
    rename_column :workspace_members, :workspace_id, :project_id
    rename_table :workspace_members, :project_members
    
    rename_column :workspace_questions, :workspace_id, :project_id
    rename_table :workspace_questions, :project_questions
    
    rename_table :workspaces, :projects
  end

  def self.down
  end
end
