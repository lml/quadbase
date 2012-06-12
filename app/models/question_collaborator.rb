# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionCollaborator < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :question_role_requests, :dependent => :destroy
  
  validates_presence_of :user, :question
  validate :question_not_published
  validates_uniqueness_of :user_id, :scope => :question_id, :message => "This user is already collaborating with this question."
  
  before_create :assign_position

  before_destroy :no_roles
  after_destroy :grant_other_requests_if_this_is_last_roleholder
  
  attr_accessible :user, :question

  def content_copy
    kopy = QuestionCollaborator.create(:user => self.user, :question => self.question)
    kopy.position = self.position
    kopy.is_author = self.is_author
    kopy.is_copyright_holder = self.is_copyright_holder
    kopy
  end
  
  # TODO validate that a question always has at least one role
  
  def self.sort(sorted_ids)
    QuestionCollaborator.transaction do
      next_position = 0
      sorted_ids.each do |sorted_id|
        collaborator = QuestionCollaborator.find(sorted_id)
        collaborator.position = next_position
        next_position += 1
        collaborator.save!
      end
    end
  end
  
  def has_role?(role)    
    case role
    when :author
      return self.is_author
    when :copyright_holder, :copyright
      return self.is_copyright_holder
    when :any
      return self.is_author || self.is_copyright_holder
    when :is_listed
      return true     
    end
  end

  def get_request(request)
    case request
      when :author
        question_role_requests.find_by_toggle_is_author(true)
      when :copyright_holder, :copyright
        question_role_requests.find_by_toggle_is_copyright_holder(true)
    end
  end
  
  def has_request?(request)
    !get_request(request).nil?
  end

  def ready_to_destroy?
    !has_role?(:any)
  end
  
  # Copies the roles that are assigned to the source question over to the 
  # target question
  def self.copy_roles(source_question, target_question)
    source_roles = QuestionCollaborator.where{question_id == source_question.id}.all
    source_roles.each do |source_role| 
      target_role = source_role.content_copy
      target_role.question_id = target_question.id
      target_role.save!
    end
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    question.is_published? ||
    (!user.is_anonymous? && question.is_project_member?(user))
  end
    
  def can_be_created_by?(user)
    !question.is_published? &&
    (!user.is_anonymous? && question.is_project_member?(user))
  end

  def can_be_destroyed_by?(user)
    !question.is_published? &&
    (!user.is_anonymous? && question.is_project_member?(user))
  end
  
  def can_be_sorted_by?(user)
    !question.is_published? &&
    (!user.is_anonymous? && question.is_project_member?(user))
  end  
  
protected

  def question_not_published
    return if !question.is_published?
    errors.add(:base, "Cannot add or change question roles after a question has been published.")
    false
  end  
  
  def assign_position
    self.position = (QuestionCollaborator.where{question_id == my{question_id}}\
                                         .maximum('position') || -1) + 1
  end

  def no_roles
    return if (!has_role?(:any))
    errors.add(:base, "Cannot remove a collaborator that has been assigned roles.")
    false
  end
  
  def grant_other_requests_if_this_is_last_roleholder
    question.grant_all_requests_if_no_role_holders_left!
  end

end
