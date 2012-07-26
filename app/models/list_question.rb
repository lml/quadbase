# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListQuestion < ActiveRecord::Base
  belongs_to :list
  belongs_to :question

  after_destroy :destroy_listless_draft_question
  
  # A published question (which is immutable) can be in any number of workgroups.
  # However, a draft question can be in only one.    
  validates_uniqueness_of :question_id, 
                          :unless => Proc.new { |wq| wq.question.is_published? }

  attr_accessible :list, :question
  
  def move!(target_list)
    source_list = self.list
    
    ListQuestion.transaction do 
      self.list = target_list
      self.save!
      
      # When the question is a multipart, and when its children are in the same
      # list as the multipart, move them too.
      if question.is_multipart?
        question.child_questions.each do |child|
          # everyone can see published questions (published questions in a list
          # doesn't really mean anything), so don't move published children.
          next if child.is_published? 

          raise IllegalState unless child.list_questions.count == 1
          child_pq = child.list_questions.first

          # If the child draft is alredy in a different list than the multipart
          # draft, skip it (only move children that are in the same list as the
          # multipart)
          next if child_pq.list != source_list

          child_pq.list = target_list 
          child_pq.save!
        end
      end
    end
  end

  def copy!(new_list, user)
    if question.is_published?
      qc = question.new_derivation!(user, new_list)
    elsif !question.latest_published_same_number.nil?
      qc = question.content_copy
      qc.create!(user, :list => new_list, :source_question => question.latest_published_same_number, :deriver_id => user.id)
    else
      qc = question.content_copy
      qc.create!(user, :list => new_list, :source_question => question.source_question, :deriver_id => user.id)
    end
    ListQuestion.find_by_list_id_and_question_id(new_list.id, qc.id)
  end

  def destroy_listless_draft_question
    question.destroy if (!question.is_published? && question.list_questions.empty?)
  end
  
  #############################################################################
  # Access control methods
  #############################################################################
    
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && list.is_member?(user)
  end

  def can_be_copied_by?(user)
    !user.is_anonymous? && (question.is_published? || list.is_member?(user))
  end
  
  def can_be_moved_by?(user)
    !user.is_anonymous? && list.is_member?(user)
  end
  
end
