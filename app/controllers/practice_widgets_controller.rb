# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class PracticeWidgetsController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter :get_list_and_question
  before_filter :include_mathjax

  def show 
  end

  def answer_text
    @answer_text = params[:answer_text]
    @answer_confidence = params[:answer_confidence].try(:to_i)
    @preview = params[:preview]
   
    respond_to do |format|
      if @answer_text.blank?
        @errors.add(:base, 'Please type your answer in the box below.')
        format.html { render :action => :show }
        format.js { render 'shared/display_flash' }
      else
        if @preview
          format.html { render 'preview_answer' }
          format.js { render 'preview_answer' }
        else
          setup_solutions_and_nav if @question.answer_choices.empty?
          format.html
          format.js
        end
      end
    end
  end
  
  def answer_choices
    raise SecurityTransgression if @question.answer_choices.empty?
    @answer_text = params[:answer_text]
    @answer_confidence = params[:answer_confidence].try(:to_i)
    @answer_choice = params[:answer_choice].try(:to_i)
    
    respond_to do |format|
    pp @answer_choice
      if @answer_choice.blank?
        @errors.add(:base, 'Please select one of the choices below.')
        format.html { render :action => :answer_text }
        format.js { render 'shared/display_flash' }
      else
        setup_solutions_and_nav
        format.html
        format.js
      end
    end
  end
  
  protected
  
  def get_list_and_question
    unless params[:list_id].nil? && params[:project_id].nil?
      @list = Project.find(params[:list_id] || params[:project_id])
      raise SecurityTransgression unless present_user.can_read?(@list)
    end
    
    if params[:question_id].nil?
      raise SecurityTransgression if @list.nil?
      @main_question = @list.questions.sample
    else
      @main_question = Question.from_param(params[:question_id])
    end
    
    raise SecurityTransgression unless present_user.can_read?(@main_question)
    
    if @main_question.is_multipart?
      @part = params[:part].try(:to_i) || 1
      parts = @main_question.child_question_parts
      raise SecurityTransgression unless parts.length >= @part
      @question = parts[@part-1].child_question
      raise SecurityTransgression unless present_user.can_read?(@question)
    else
      @question = @main_question
    end
    @errors = @question.errors
  end
  
  def setup_solutions_and_nav
    @solutions = @question.solutions.visible_for(present_user)
    if @main_question.is_multipart? && @main_question.child_question_parts.length > @part
      @next_question = @main_question
      @next_part = @part + 1
    elsif !@list.nil?
      @next_question = @list.questions.reject{|q| q == @main_question}.sample
    end
  end
  
  def include_mathjax
    @include_mathjax = true
  end

end
