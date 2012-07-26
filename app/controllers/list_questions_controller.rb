# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListQuestionsController < ApplicationController

  before_filter :assign_list_variables

  def update
    return preview_publish if params[:publish]
    return copy if params[:copy]
    return move if params[:move]
    return attribution if params[:attribution]
    return destroy if params[:remove]

    respond_to do |format|
      flash[:alert] = "Invalid parameters."
      format.html { redirect_to list_path(@list_questions.first.list) }
      format.js
    end
  end

  def destroy
    ListQuestion.transaction do 
      @list_questions.each do |wq|
        raise SecurityTransgression unless present_user.can_destroy?(wq)
        wq.destroy
      end
    end
    
    respond_to do |format|
      flash[:notice] = ((@list_questions.size == 1) ? "Question" : "Questions")  +
                       " removed from the list."
      format.html { redirect_to list_path(@list) }
      format.js { render 'list_questions/destroy' }
    end
  end

  def attribution
    @questions = @list_questions.collect{ |wq| wq.question }
    @question_ids = @questions.collect{ |q| q.id }

    respond_to do |format|
      format.html # attribution.html.erb
      format.js # attribution.js.erb
    end
  end
  
  def preview_publish
    @questions = @list_questions.collect{ |wq| wq.question }
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
         !(target_list = List.find_by_id(params[:copy].first))

    raise SecurityTransgression unless \
      present_user.can_update?(target_list) && 
      @list_questions.all?{|pq| pq.can_be_copied_by?(present_user)}

    ListQuestion.transaction do 
      @list_questions.each do |pq|
        pq.copy!(target_list, present_user)
      end
    end

    respond_to do |format|
      flash[:notice] = ((@list_questions.size == 1) ? "Copy" : "copies")  +
                       " added to " + target_list.name.to_s + "."
      format.html { redirect_to list_path(@list) }
      format.js
    end
  end
  
  def move
    (render :nothing => true && return) \
      if params[:move].blank? ||
         !(target_list = List.find_by_id(params[:move].first))
         
    raise SecurityTransgression unless \
      present_user.can_update?(target_list) && 
      @list_questions.all?{|pq| pq.can_be_moved_by?(present_user)}

    ListQuestion.transaction do 
      @list_questions.each do |wq|
        wq.move!(target_list)
      end
    end
    
    respond_to do |format|
      flash[:notice] = ((@list_questions.size == 1) ? "Question" : "Questions")  +
                       " moved to " + target_list.name.to_s + "."
      format.html { redirect_to list_path(@list) }
      format.js
    end
  end

private

  def assign_list_variables
    if !(@list = List.find_by_id(params[:list_id]))
      render :nothing => true
      return
    end
    if params[:list_question_ids]
      @list_questions = ListQuestion.find(params[:list_question_ids])
    else
      respond_to do |format|
        flash[:alert] = "You must select one or more questions before performing this action."
        format.html { redirect_to list_path(@list) }
        format.js { render 'shared/display_flash' }
      end
    end
  end

end
