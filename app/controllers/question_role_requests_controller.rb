# Copyright (c) 2011 Rice University.  All rights reserved.

class QuestionRoleRequestsController < ApplicationController
  
  before_filter :get_request, :except => :create
  
  def create
    @collaborator_id = params[:question_role_request][:question_collaborator_id]
    @collaborator = QuestionCollaborator.find(@collaborator_id)
    params[:question_role_request][:question_collaborator] = @collaborator

    @question_role_request = QuestionRoleRequest.new(params[:question_role_request])
    @question_role_request.requestor = current_user

    raise SecurityTransgression unless present_user.can_create?(@question_role_request)

    respond_to do |format|
      if @question_role_request.save
        # Javascript needs to know collaborator object after save, plus it needs to be reloaded
        @collaborator = @question_role_request.question_collaborator.reload
        
        format.html { redirect_to question_question_collaborators_path(@collaborator.question) }
        format.js
      else
        flash[:alert] = @question_role_request.errors.values.to_sentence
        format.json { render :json => @question_role_request.errors, :status => :unprocessable_entity }
        format.js
      end
    end
    
  end

  def destroy
    raise SecurityTransgression unless @question_role_request.can_be_destroyed_by?(present_user)
    @question_role_request.destroy

    # Javascript needs to know collaborator object after save, plus it needs to be reloaded
    @collaborator = @question_role_request.question_collaborator.reload

    respond_to do |format|
        format.html { redirect_to question_question_collaborators_path(@collaborator.question) }
        format.js
    end

  end
  
  def accept
    raise SecurityTransgression unless @question_role_request.can_be_accepted_by?(present_user)
    
    respond_to do |format|
      if @question_role_request.accept!
        format.html { redirect_to inbox_path }
        format.js { render 'adjudicated' }
      else
        format.json { render :json => @question_role_request.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def reject
    raise SecurityTransgression unless @question_role_request.can_be_rejected_by?(present_user)

    respond_to do |format|
      if @question_role_request.reject!
        format.html { redirect_to inbox_path }
        format.js { render 'adjudicated' }
      else
        format.json { render :json => @question_role_request.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def approve
    raise SecurityTransgression unless @question_role_request.can_be_approved_by?(present_user)

    respond_to do |format|
      if @question_role_request.approve!
        format.html { redirect_to inbox_path }
        format.js { render 'adjudicated' }
      else
        format.json { render :json => @question_role_request.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  def veto
    raise SecurityTransgression unless @question_role_request.can_be_vetoed_by?(present_user)
    
    respond_to do |format|
      if @question_role_request.veto!
        format.html { redirect_to inbox_path }
        format.js { render 'adjudicated' }
      else
        format.json { render :json => @question_role_request.errors, :status => :unprocessable_entity }
      end
    end
  end
  
protected

  def get_request
    @question_role_request = 
      QuestionRoleRequest.find(params[:question_role_request_id] || params[:id])                          
  end

end
