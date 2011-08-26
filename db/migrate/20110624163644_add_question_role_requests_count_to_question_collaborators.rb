class AddQuestionRoleRequestsCountToQuestionCollaborators < ActiveRecord::Migration
  def self.up
    add_column :question_collaborators, :question_role_requests_count, :integer, :default => 0  
      
    QuestionCollaborator.reset_column_information  
    QuestionCollaborator.all.each do |qc|  
      QuestionCollaborator.update_counters qc.id,
        :question_role_requests_count => qc.question_role_requests.length  
    end
  end

  def self.down
    remove_column :question_collaborators, :question_role_requests_count
  end
end
