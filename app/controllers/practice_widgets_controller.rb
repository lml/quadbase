# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class PracticeWidgetsController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter :get_question
  before_filter :include_mathjax

  def show 
  end

  def answer_text
    @answer_text = params[:answer_text]
    @answer_confidence = params[:answer_confidence].to_i
    @preview = params[:preview]
    @solutions = @question.solutions.visible_for(present_user) \
      if @question.answer_choices.empty?
   
    respond_to do |format|
      if @answer_text
        if @preview
          format.html { render 'preview_answer' }
          format.js { render 'preview_answer' }
        else
          format.html
          format.js
        end
      else
        format.html { render :action => :show }
      end
    end
  end
  
  def answer_choices
    raise SecurityTransgression if @question.answer_choices.empty?
    @answer_text = params[:answer_text]
    @answer_confidence = params[:answer_confidence].to_i
    @answer_choice = params[:answer_choice].to_i
    @solutions = @question.solutions.visible_for(present_user)
    
    respond_to do |format|
      if @answer_choice
        format.html
        format.js
      else
        format.html { render :action => :text_answer }
      end
    end
  end
  
  protected
  
  def get_question
    @main_question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_read?(@main_question)
    
    if @main_question.is_multipart?
      @part = params[:part].try(:to_i) || 1
      parts = @main_question.child_question_parts
      raise SecurityTransgression unless parts.length >= @part
      if parts.length > @part
        @next_question = @main_question
        @next_part = @part + 1
      end
      @question = parts[@part-1].child_question
      raise SecurityTransgression unless present_user.can_read?(@question)
    else
      @question = @main_question
    end
  end
  
  def include_mathjax
    @include_mathjax = true
  end

end
