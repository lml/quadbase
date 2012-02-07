# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionCollaboratorsController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper

  before_filter { @use_columns = true }
  before_filter :include_jquery

  layout 'questions', :only => :index

  before_filter :get_question
  
  helper :questions

  def new
    @action_dialog_title = "Add a collaborator"
    @action_search_path = search_question_question_collaborators_path(params[:question_id])
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  def search
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      @question.is_collaborator?(user)
    end    
    
    @action_partial = 'question_collaborators/create_question_collaborator_form'
    
    respond_to do |format|
      format.js { render :template => 'users/action_search' }
    end
  end

  def index
    @question_collaborators = @question.question_collaborators
    raise SecurityTransgression unless present_user.can_read?(@question)
    @add_path = question_question_collaborators_path(@question)
    respond_with(@question_collaborators)    
  end

  def show
    @question_collaborator = QuestionCollaborator.find(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@question_collaborator)
    respond_with(@question_collaborator)
  end

  def create
    @question_collaborators = @question.question_collaborators
    
    username = params[:question_collaborator][:username]
    user = User.find_by_username(username) 
  
    if user.nil?
      flash[:alert] = 'User ' + username + ' not found!'
      respond_to do |format|
        format.html { redirect_to question_question_collaborators_path(@question) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => {:base => 'Username not found.'}, :status => :unprocessable_entity }
      end
      return
    end
  
    @question_collaborator = QuestionCollaborator.new(:user => user, :question => @question)
    
    raise SecurityTransgression unless present_user.can_create?(@question_collaborator)
    
    respond_to do |format|
      if @question_collaborator.save
        format.html { redirect_to question_question_collaborators_path(@question) }
        format.js
      else
        flash[:alert] = get_error_messages(@question_collaborator)
        format.html { redirect_to question_question_collaborators_path(@question) }
        format.js { render :action => 'shared/display_flash' }
        format.json { render :json => @question_collaborator.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @question_collaborator = QuestionCollaborator.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@question_collaborator)

    @destroy = @question_collaborator.ready_to_destroy? ||
               present_user.id == @question_collaborator.user_id

    QuestionRoleRequest.request_drop_all_roles(@question_collaborator, present_user)

    if @destroy
      @question_collaborator.destroy
    end

    respond_with(@question_collaborator) do |format|
      format.html { redirect_to question_question_collaborators_path(@question) }
      format.js
    end
  end

  def sort
    sorted_collaborator_ids = params['collaborator']
    return if sorted_collaborator_ids.nil?
    raise SecurityTransgression unless 
      QuestionCollaborator.find(sorted_collaborator_ids.first).can_be_sorted_by?(present_user)
      
    QuestionCollaborator.sort(sorted_collaborator_ids)
    render :nothing => true
  end
  
private

  def get_question
    @question = params[:question_id].nil? ? nil : Question.from_param(params[:question_id])
  end
end
