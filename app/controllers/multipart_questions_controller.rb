# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class MultipartQuestionsController < ApplicationController

  before_filter :get_multipart_question, :only => [:add_blank_part, :add_existing_parts]

  def add_blank_part
    raise SecurityTransgression unless present_user.can_update?(@multipart_question)

    new_question = SimpleQuestion.new
    new_question.question_setup_id = @multipart_question.question_setup_id
    raise SecurityTransgression unless present_user.can_create?(new_question)
    new_question.create!(current_user)
  
    respond_to do |format|
      if @multipart_question.add_parts(new_question)
        @new_part = @multipart_question.last_part
        @all_parts = @multipart_question.child_question_parts
        format.js
      else
        flash[:alert] = @multipart_question.errors.values.to_sentence
        format.html { redirect_to edit_question_path(@multipart_question) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => @multipart_question.errors, :status => :unprocessable_entity }        
      end
    end
  end
  
  def add_existing_parts
    raise SecurityTransgression unless present_user.can_update?(@multipart_question)
    child_questions = params[:question_ids].collect{|id| Question.find(id)}
    
    respond_to do |format|
      if @multipart_question.add_parts(child_questions)
        format.html { redirect_to edit_question_path(@multipart_question) }
        format.js
      else
        flash[:alert] = @multipart_question.errors.values.to_sentence
        format.html { redirect_to edit_question_path(@multipart_question) }
        format.js
        format.json { render :json => @multipart_question.errors, :status => :unprocessable_entity }
      end
    end
  end
  
protected
  
  def get_multipart_question
    @multipart_question = Question.from_param(params[:multipart_question_id])
  end

end
