class PracticeController < ApplicationController
  
  skip_before_filter :authenticate_user!
  before_filter :include_mathjax

  def show
    @question = current_question
    raise SecurityTransgression unless present_user.can_read?(@question)
  end

  def submit_answer
  end

protected

  def current_question
    question = Question.from_param(current_question_id)

    if question.is_multipart?
      @part = (params[:part] || 0).to_i
      if @part >= question.num_parts
        @index += 1
        question = Question.from_param(current_question_id)
        @part = question.is_multipart? ? 0 : nil
      elsif @part < 0
        @index -= 1
        question = Question.from_param(current_question_id)
        @part = question.is_multipart? ? question.num_parts-1 : nil
      end
    end

    if question.is_multipart?
      question = question.child_questions[@part]
    end

    question
  end

  def current_question_id
    raise ActiveRecord::RecordNotFound if question_ids.length == 0
    # Sometimes @index is set as in current_question, sometimes we load from params
    @index ||= (params[:on] || 0).to_i
    @index %= question_ids.length
    question_ids[@index]
  end

  def question_ids
    if @question_ids.nil?
      @question_ids = []

      ids = params[:ids].split(",")

      ids.each do |id| 
        case id.downcase
        when /^[q|d]/
          @question_ids.push(id)
        when /^l(\d+)$/
          list_question_ids = ListQuestion.where{list_id == my{$1}}.
                                           order{created_at.asc}.
                                           all.
                                           collect{|lq| lq.question_id}
          @question_ids.concat(list_question_ids)
        end
      end

      srand(20) # could be based on user ID
      @question_ids.sort_by!{rand}
    end

    @question_ids
  end

end
