# Copyright (c) 2011 Rice University.  All rights reserved.

class ProjectQuestion < ActiveRecord::Base
  belongs_to :project
  belongs_to :question
  
  # A published question (which is immutable) can be in any number of workgroups.
  # However, a draft question can be in only one.    
  validates_uniqueness_of :question_id, 
                          :unless => Proc.new { |wq| wq.question.is_published? }

  attr_accessible :project, :question
  
  def move!(new_project)
    self.project = new_project
    self.save!
  end

  def copy!(new_project, user)
    if question.is_published?
      question.new_derivation!(user, new_project)
    elsif !question.latest_published_same_number.nil?
      question.latest_published_same_number.new_derivation!(user, new_project)
    else
      qc = question.content_copy
      qc.create!(user, :project => new_project, :source_question => question.source_question, :deriver_id => user.id)
    end
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
