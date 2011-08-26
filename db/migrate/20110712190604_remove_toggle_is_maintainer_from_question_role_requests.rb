class RemoveToggleIsMaintainerFromQuestionRoleRequests < ActiveRecord::Migration
  def self.up
    remove_column :question_role_requests, :toggle_is_maintainer
  end

  def self.down
    add_column :question_role_requests, :toggle_is_maintainer, :boolean
  end
end
