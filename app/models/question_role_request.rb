# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionRoleRequest < ActiveRecord::Base
  belongs_to :question_collaborator, :counter_cache => true
  belongs_to :requestor, :class_name => "User"
  
  validate :no_duplicate_requests, :on => :create
  validate :valid_request

  scope :for_question, lambda { |question|
    joins{question_collaborator}.where{question_collaborators.question_id == question.id}
  }

  attr_accessible :question_collaborator, :toggle_is_author, :toggle_is_copyright_holder,
                  :is_approved, :is_accepted, :question_collaborator_id
  
  before_create :autoset_approved_and_accepted
  after_create :execute_if_ready!

  def initialize(attributes = nil, options = {})
    @has_been_executed = false
    super(attributes, options)
  end
  
  def self.approvable_by(user)
    # TODO the implementation below is not efficient.  There must be some cool 
    # metawhere query or scope that we can use to do this more efficiently.
    # 
    # Ideas:
    #   1) get all pending collaborators
    #   2) get those collaborator's active peers (this should be a scope/relation)
    #         "active" means they are either an author or copyright holder already
    #   3) filter those down to those where the user is the given user 
    #      OR a deputizer of the given user (scope/relation?)
    #   4) save off the question_ids from these filtered collaborators
    #   5) Join QRR and QC, select QRR.* where question_id in (4)'s array
    
    requests = QuestionRoleRequest.all
    requests.select{|r| r.can_be_approved_by?(user)}
  end
  
  def self.acceptable_by(user)
    # TODO not efficient either (see above)
    #
    #   OLD WAY (pre-deputies)
    #   requests = user.question_collaborators.collect{|qc| qc.question_role_requests}.flatten
    #   requests.reject{|r| r.is_accepted}
    
    requests = QuestionRoleRequest.all
    requests.select{|r| r.can_be_accepted_by?(user)}
  end
  
  # We use this method instead of "has_one :question, :through => question_collaborators"
  # because we need to be able to use this call before the request is saved.
  def question
    question_collaborator.question
  end
  
  # If the requestor has approval or acceptance permission for this request, go ahead
  # and set those fields to true.
  def autoset_approved_and_accepted
    # This request should be automatically approved if (1) it drops a role (in which
    # case no approval is needed), (2) the request can be approved by the requestor, or
    # (3) there are no collaborators available who can approve the request.
    self.is_approved ||= drops_role? || 
                         can_be_approved_by?(requestor) ||
                         question.question_collaborators.none?{|qc| can_be_approved_by?(qc.user)}
    
    # The request should be automatically accepted iff the requestor can accept it
    self.is_accepted ||= can_be_accepted_by?(requestor)
    
    # If "before_*" callbacks return false, the save in progress is canceled.
    # It may just happen that the "self.is_accepted ||=" line returns false, 
    # but we don't want that to kill the save.  So return true.
    return true
  end
  
  # If the autosetting from above has resulted in a request that is ready to run,
  # go ahead and execute it.
  def execute_if_ready!
    execute! if (is_accepted && is_approved)
  end
  
  def approve!
    is_accepted ? execute! : update_attributes({:is_approved => true})
  end
  
  def veto!
    destroy_and_notify(:after_veto)
  end
  
  def accept!
    is_approved ? execute! : update_attributes({:is_accepted => true})
  end
  
  def reject!
    destroy_and_notify(:after_reject)
  end
  
  def grant!
    execute!
  end
  
  def destroy_and_notify(callback = nil)
    if self.destroy
      notify_observers(callback) if !callback.nil?
      true
    else
      false
    end
  end
  
  def requestee
    question_collaborator.user
  end
  
  def is_a_self_request?
    requestee.id == requestor_id
  end
  
  # Returns true iff the given user is the one who will receive the role if granted.
  def is_requestee?(user)
    requestee.id == user.id
  end
  
  def is_requestor?(user)
    user.id == requestor.id
  end
  
  def drops_role?
    does_drop = (toggle_is_author && question_collaborator.is_author) ||
                (toggle_is_copyright_holder && question_collaborator.is_copyright_holder)

    # When this request has already been executed, the result we get from
    # above is actually flipped, so flip it back here.
    has_been_executed ? !does_drop : does_drop
  end
  
  def adds_role?
    !drops_role?
  end

  def self.request_drop_all_roles(collaborator, requestor)
    roles = [:author, :copyright_holder]
    toggles = [:toggle_is_author, :toggle_is_copyright_holder]
    roles.each_with_index do |role, i|
      if collaborator.has_role?(role) && !collaborator.has_request?(role)
        qrr = new(:question_collaborator => collaborator,
                  toggles[i] => true)
        qrr.requestor = requestor
        qrr.save!
      elsif !collaborator.has_role?(role) && collaborator.has_request?(role)
        collaborator.get_request(role).destroy
      end
    end
  end
  
  #############################################################################
  # Access control methods
  # 
  # Note that approving and vetoing are only done when the role is being added.
  #############################################################################
    
  def can_be_created_by?(user)
    question.role_requests_can_be_created_by?(user)
  end
  
  def can_be_approved_by?(user)
    !is_approved &&
    !user.is_anonymous? && adds_role? && question.has_role_permission?(user, :any)
  end
  
  def can_be_vetoed_by?(user)
    !user.is_anonymous? && adds_role? && question.has_role_permission?(user, :any)
  end
  
  def can_be_accepted_by?(user)
    !user.is_anonymous? && (is_requestee?(user) || user.is_deputy_for?(requestee))
  end

  def can_be_rejected_by?(user)
    !user.is_anonymous? && (is_requestee?(user) || user.is_deputy_for?(requestee))
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && is_requestor?(user)
  end
  
protected

  attr_accessor :has_been_executed

  def execute!
    qc = question_collaborator
    
    qc.is_author = !qc.is_author if self.toggle_is_author
    qc.is_copyright_holder = !qc.is_copyright_holder if self.toggle_is_copyright_holder
    
    # Use a temporary variable to store that we have executed the request; this 
    # is useful in the observer code below before this object is destroyed
    self.has_been_executed = true
    
    if qc.save
      notify_observers(:after_execute)
      result = self.destroy
      qc.question.comment_thread.subscribe!(qc.user)
      qc.reload
      qc.destroy if qc.ready_to_destroy?
      result
    else
      qc.errors.each{|attr,msg| self.errors.add(attr, msg)}
    end
  end

  def no_duplicate_requests
    return if !QuestionRoleRequest.where{(question_collaborator_id == my{question_collaborator_id}) &\
                                         (toggle_is_author == my{toggle_is_author}) &\
                                         (toggle_is_copyright_holder == my{toggle_is_copyright_holder})}.any?
    errors.add(:base, "That request has already been made.")
    false
  end

  def valid_request
    # ^ is XOR in ruby. We want one of these to be true, but not both.
    return if (toggle_is_author ^ toggle_is_copyright_holder)
    errors.add(:base, "Each role request must refer to exactly one role.")
    false
  end

end
