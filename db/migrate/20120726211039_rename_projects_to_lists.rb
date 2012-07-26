class RenameProjectsToLists < ActiveRecord::Migration
  def up
    rename_table :projects, :lists
    rename_table :project_members, :list_members
    rename_column :list_members, :project_id, :list_id
    rename_table :project_questions, :list_questions
    rename_column :list_questions, :project_id, :list_id
    rename_column :user_profiles, :project_member_email, :list_member_email
    
    CommentThread.all.each do |ct|
      if ct.commentable_type == 'Project'
        ct.update_attribute :commentable_type, 'List'
      end
    end
  end

  def down
    rename_table :lists, :projects
    rename_table :list_members, :project_members
    rename_column :project_members, :list_id, :project_id
    rename_table :list_questions, :project_questions
    rename_column :project_questions, :list_id, :project_id
    rename_column :user_profiles, :list_member_email, :project_member_email
    
    CommentThread.all.each do |ct|
      if ct.commentable_type == 'List'
        ct.update_attribute :commentable_type, 'Project'
      end
    end
  end
end
