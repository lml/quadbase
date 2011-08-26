# Copyright (c) 2011 Rice University.  All rights reserved.

class QuestionRoleRequestObserver < ActiveRecord::Observer
  def after_create(question_role_request)
    # We need the requestee to approve/reject the request unless it is already
    # done (which happens when the requestee is also the requestor)
    RoleRequestNotifier.need_requestee_action_email(question_role_request) \
      if !question_role_request.is_accepted

    # We need the collaborators to approve/veto the request when the request
    # is an add request and when the request hasn't already been approve (which
    # happens when the requestor is also a collaborator)
    RoleRequestNotifier.need_collaborator_action_email(question_role_request) \
      if question_role_request.adds_role? && !question_role_request.is_approved
  end
  
  def after_execute(question_role_request)
    RoleRequestNotifier.executed_email(question_role_request)
  end
  
  def after_veto(question_role_request)
    RoleRequestNotifier.vetoed_email(question_role_request)
  end
  
  def after_reject(question_role_request)
    RoleRequestNotifier.rejected_email(question_role_request)
  end
  
end