class ChangeWorkspaceToProjectInDb < ActiveRecord::Migration
  def self.up
    CommentThread.all.each do |ct| 
      ct.update_attribute(:commentable_type, "Project") if ct.commentable_type == "Workspace"
    end
  end

  def self.down
  end
end
