class AddFieldsToQuestionRoleRequest < ActiveRecord::Migration
  def self.up
    add_column :question_role_requests, :is_approved, :boolean, :default => false
    add_column :question_role_requests, :is_accepted, :boolean, :default => false
  end

  def self.down
    remove_column :question_role_requests, :is_approved
    remove_column :question_role_requests, :is_accepted
  end
end
