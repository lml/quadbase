# Copyright (c) 2011 Rice University.  All rights reserved.

class RoleRequestNotifier < QuadbaseMailer
  helper :question_role_requests

  def need_requestee_action_email(role_request) 
    setup_variables(role_request)
    return if !@requestee.user_profile.role_request_email
    
    mail(:to => @requestee.email,
         :subject => "Please accept or reject a role request for question #{@question.number}").deliver    
  end
  
  def need_collaborator_action_email(role_request)
    setup_variables(role_request)
    
    # Build up the list of (role-holding) collaborators and their deputies
    question_collaborators = 
      @question.question_collaborators.select{|qc| qc.has_role?(:any)}

    collaborators = question_collaborators.collect{|qc| qc.user}
    deputies = collaborators.collect{|c| c.deputies}.flatten
    
    # Combine them into one list
    recipients = [collaborators, deputies].flatten
    
    send_private_mail(recipients, 
                      "Please approve or veto a role request " + 
                      "for question #{@question.number}")
  end

  def executed_email(role_request)
    setup_variables(role_request)
    
    recipients = [@requestee, @requestor]
    
    send_private_mail(recipients, 
                      "Role request granted for #{@requestee.full_name} on " + 
                      "question #{@question.number}")
  end
  
  def vetoed_email(role_request)
    setup_variables(role_request)

    recipients = [@requestee, @requestor]

    send_private_mail(recipients, 
                      "Role request vetoed for #{@requestee.full_name} on " + 
                      "question #{@question.number}")    
  end
  
  def rejected_email(role_request)
    setup_variables(role_request)

    recipients = [@requestor]

    send_private_mail(recipients, 
                      "Role request rejected by #{@requestee.full_name} for " + 
                      "question #{@question.number}")
  end
  
private

  def send_private_mail(recipients, subject) 
    recipients.reject!{|r| !r.user_profile.role_request_email }
    recipients.uniq!
    send_type = recipients.count == 1 ? :to : :bcc
    emails = recipients.collect{|r| r.email}.uniq
    
    return if emails.empty?
    
    mail(send_type => emails, :subject => subject).deliver
  end

  def setup_variables(role_request)
    @requestee = role_request.question_collaborator.user
    @requestor = role_request.requestor
    @question = role_request.question
    @role_request = role_request
  end
  
end
