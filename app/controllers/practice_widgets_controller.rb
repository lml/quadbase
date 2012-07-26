# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class PracticeWidgetsController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter :embed
  before_filter :get_list_and_question, :only => :show
  before_filter :get_question, :except => :show
  before_filter :include_mathjax

  def show
    GoogleAnalyticsWrapper.new(cookies).event('Practice Widget', 'Answer (show)', @layout)
    render :layout => @layout
  end

  def answer_text
    @answer_text = params[:answer_text]
    @answer_confidence = params[:answer_confidence].try(:to_i)
    @preview = params[:preview]
   
    respond_to do |format|
      if @preview
        GoogleAnalyticsWrapper.new(cookies).event('Practice Widget', 'Preview Answer', @answer_text, @answer_confidence)
        format.html { render 'preview_answer', :layout => @layout }
        format.js { render 'preview_answer', :layout => @layout }
      else
        GoogleAnalyticsWrapper.new(cookies).event('Practice Widget', 'Answer (text)', @answer_text, @answer_confidence)
        setup_solutions_and_nav if @question.answer_choices.empty?
        format.html { render :layout => @layout }
        format.js { render :layout => @layout }
      end
    end
  end
  
  def answer_choices
    raise SecurityTransgression if @question.answer_choices.empty?
    @answer_text = params[:answer_text]
    @answer_confidence = params[:answer_confidence].try(:to_i)
    @answer_choice = params[:answer_choice].try(:to_i)
    raise SecurityTransgression unless @answer_choice < @question.answer_choices.length
    
    GoogleAnalyticsWrapper.new(cookies).event('Practice Widget', 'Answer (choices)', @question.answer_choices[@answer_choice], @answer_choice)
    
    respond_to do |format|
      setup_solutions_and_nav
      format.html { render :layout => @layout }
      format.js { render :layout => @layout }
    end
  end
  
  protected
  
  def embed
    @layout = params[:embed] ? 'embed' : 'application'
  end
  
  def get_question
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
    
    @seed = params[:seed] || rand(2e8)
    @question.variate!(QuestionVariator.new(@seed))
  end
  
  def get_list_and_question
    unless params[:list_id].nil? && params[:project_id].nil?
      @list = Project.find(params[:list_id] || params[:project_id])
      raise SecurityTransgression unless present_user.can_read?(@list)
    end
    
    get_question
  end
  
  def include_mathjax
    @include_mathjax = true
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

end
