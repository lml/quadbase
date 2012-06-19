# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionPart < ActiveRecord::Base
  belongs_to :multipart_question
  belongs_to :child_question, :class_name => 'Question'
  
  validates_presence_of :multipart_question_id, :child_question_id
  validates_uniqueness_of :child_question_id, :scope => :multipart_question_id
  validates_uniqueness_of :order, :scope => :multipart_question_id, :allow_nil => true
  # nil is used as a temporary value to avoid conflicts when sorting
  
  before_create :assign_order

  attr_accessible :order
  
  def content_copy
    child_question_copy = child_question.is_published? ? 
                          child_question : 
                          child_question.content_copy
                          
    kopy = QuestionPart.new(:order => order)
    kopy.multipart_question = multipart_question
    kopy.child_question = child_question_copy
    kopy
  end

  def unlock!(user)
    return false if !child_question.is_published?
    self.child_question = child_question.new_derivation!(user, multipart_question.project)
    self.save!
    multipart_question.check_and_unlock_setup!
    true
  end

  def self.sort(sorted_ids)
    QuestionPart.transaction do
      next_position = 1
      sorted_ids.each do |sorted_id|
        part = QuestionPart.find(sorted_id)
        if (part.order != next_position) && (
             conflicting_part = QuestionPart.find_by_order_and_multipart_question_id(
                                               next_position, part.multipart_question_id))
          conflicting_part.order = nil
          conflicting_part.save!
        end
        part.order = next_position
        next_position += 1
        part.save!
      end
    end
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  # def can_be_read_by?(user)
  #   !user.is_anonymous? && ...
  # end
  #   
  # def can_be_created_by?(user)
  #   !user.is_anonymous?
  # end

  def can_be_updated_by?(user)
    !user.is_anonymous? && multipart_question.can_be_updated_by?(user)
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && multipart_question.can_be_updated_by?(user)
  end

  def can_be_sorted_by?(user)
    !user.is_anonymous? && multipart_question.can_be_updated_by?(user)
  end
  
protected
  
  # Opting to go with 1-based indexing here; the first part will likely be
  # referred to as part "1", so better for the order number to match
  def assign_order
    self.order ||= (QuestionPart.where{multipart_question_id == my{multipart_question_id}} \
                                .maximum('order') || 0) + 1
  end
  
  
end
