# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ProjectQuestionsController < ApplicationController

  before_filter :assign_project_variables

  def update
    return preview_publish if params[:publish]
    return copy if params[:copy]
    return move if params[:move]
    return attribution if params[:attribution]
    return destroy if params[:remove]

    respond_to do |format|
      flash[:alert] = "Invalid parameters."
      format.html { redirect_to project_path(@project_questions.first.project) }
      format.js
    end
  end

  def destroy
    ProjectQuestion.transaction do 
      @project_questions.each do |wq|
        raise SecurityTransgression unless present_user.can_destroy?(wq)
        wq.destroy
      end
    end
    
    respond_to do |format|
      flash[:notice] = ((@project_questions.size == 1) ? "Question" : "Questions")  +
                       " removed from the project."
      format.html { redirect_to project_path(@project) }
      format.js { render 'project_questions/destroy' }
    end
  end

  def attribution
    @questions = @project_questions.collect{ |wq| wq.question }
    @question_ids = @questions.collect{ |q| q.id }

    respond_to do |format|
      format.html # attribution.html.erb
      format.js # attribution.js.erb
    end
  end
  
  def preview_publish
    @questions = @project_questions.collect{ |wq| wq.question }
    @question_ids = @questions.collect{ |q| q.id }
    
    run_prepublish_error_checks(@questions)
    
    respond_to do |format|
      format.html { render :template => "questions/preview_publish" }
      format.js
    end
  end

  def copy
    (render :nothing => true && return) \
      if params[:copy].blank? ||
         !(target_project = Project.find_by_id(params[:copy].first))

    raise SecurityTransgression unless \
      present_user.can_update?(target_project) && 
      @project_questions.all?{|pq| pq.can_be_copied_by?(present_user)}

    @copied_questions = Array.new
    ProjectQuestion.transaction do 
      if target_project == @project
        @copied_questions = @project_questions.collect{ |pq|
          pq.copy!(target_project, present_user)      }
      else
        @project_questions.each do |pq|
          pq.copy!(target_project, present_user)
        end
      end
    end

    respond_to do |format|
      flash[:notice] = ((@project_questions.size == 1) ? "Copy" : "copies")  +
                       " added to " + target_project.name.to_s + "."
      format.html { redirect_to project_path(@project) }
      format.js
    end
  end
  
  def move
    (render :nothing => true && return) \
      if params[:move].blank? ||
         !(target_project = Project.find_by_id(params[:move].first))
         
    raise SecurityTransgression unless \
      present_user.can_update?(target_project) && 
      @project_questions.all?{|pq| pq.can_be_moved_by?(present_user)}

    ProjectQuestion.transaction do 
      @project_questions.each do |wq|
        wq.move!(target_project)
      end
    end
    
    respond_to do |format|
      flash[:notice] = ((@project_questions.size == 1) ? "Question" : "Questions")  +
                       " moved to " + target_project.name.to_s + "."
      format.html { redirect_to project_path(@project) }
      format.js
    end
  end

private

  def assign_project_variables
    if !(@project = Project.find_by_id(params[:project_id]))
      render :nothing => true
      return
    end
    if params[:project_question_ids]
      @project_questions = ProjectQuestion.find(params[:project_question_ids])
    else
      respond_to do |format|
        flash[:alert] = "You must select one or more questions before performing this action."
        format.html { redirect_to project_path(@project) }
        format.js { render 'shared/display_flash' }
      end
    end
  end

end
