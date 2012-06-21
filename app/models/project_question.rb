# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ProjectQuestion < ActiveRecord::Base
  belongs_to :project
  belongs_to :question

  after_destroy :destroy_projectless_draft_question
  
  # A published question (which is immutable) can be in any number of workgroups.
  # However, a draft question can be in only one.    
  validates_uniqueness_of :question_id, 
                          :unless => Proc.new { |wq| wq.question.is_published? }

  attr_accessible :project, :question
  
  def move!(target_project)
    source_project = self.project
    
    ProjectQuestion.transaction do 
      self.project = target_project
      self.save!
      
      # When the question is a multipart, and when its children are in the same
      # project as the multipart, move them too.
      if question.is_multipart?
        question.child_questions.each do |child|
          # everyone can see published questions (published questions in a project
          # doesn't really mean anything), so don't move published children.
          next if child.is_published? 

          raise IllegalState unless child.project_questions.count == 1
          child_pq = child.project_questions.first

          # If the child draft is alredy in a different project than the multipart
          # draft, skip it (only move children that are in the same project as the
          # multipart)
          next if child_pq.project != source_project

          child_pq.project = target_project 
          child_pq.save!
        end
      end
    end
  end

  def copy!(new_project, user)
    if question.is_published?
      qc = question.new_derivation!(user, new_project)
    elsif !question.latest_published_same_number.nil?
      qc = question.content_copy
      qc.create!(user, :project => new_project, :source_question => question.latest_published_same_number, :deriver_id => user.id)
    else
      qc = question.content_copy
      qc.create!(user, :project => new_project, :source_question => question.source_question, :deriver_id => user.id)
    end
    ProjectQuestion.find_by_project_id_and_question_id(new_project.id, qc.id)
  end

  def destroy_projectless_draft_question
    question.destroy if (!question.is_published? && question.project_questions.empty?)
  end
  
  #############################################################################
  # Access control methods
  #############################################################################
    
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && project.is_member?(user)
  end

  def can_be_copied_by?(user)
    !user.is_anonymous? && (question.is_published? || project.is_member?(user))
  end
  
  def can_be_moved_by?(user)
    !user.is_anonymous? && project.is_member?(user)
  end
  
end
