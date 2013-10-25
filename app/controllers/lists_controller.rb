# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index, :show, :practice]
  before_filter :include_jquery, :only => [:show, :index]
  before_filter :include_mathjax, :only => :show

  before_filter :use_2_column_layout
  before_filter {select_tab(:lists)}

  helper :questions

  def index
    respond_with(@lists = List.visible_for(present_user))
  end

  def show
    @list = List.find(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@list)
    unless current_user.nil?
      @target_lists = current_user.lists.reject { |w| w == @list}
      @all_lists = current_user.lists
    end
    respond_with(@list)
  end

  def new
    respond_with(@list = List.new)
  end

  def edit
    @list = List.find(params[:id])
    raise SecurityTransgression unless present_user.can_update?(@list)
    respond_with(@list)
  end

  def create
    @list = List.new(params[:list])
    raise SecurityTransgression unless present_user.can_create?(@list)
    
    List.transaction do
      @list.save
      @list.add_member!(current_user)
    end
    respond_with(@list)
  end

  def update
    @list = List.find(params[:id])
    raise SecurityTransgression unless present_user.can_update?(@list)
    @list.update_attributes(params[:list])
    respond_with(@list)
  end

  def destroy
    @list = List.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@list)
    @list.destroy
    respond_with(@list)
  end

  def embed
    @list = List.find(params[:list_id])
    raise SecurityTransgression unless present_user.can_read?(@list)
  end

  # GET /lists/1/practice.json?number_of_questions=10&exclude_ids[]=1&exclude_ids[]=2
  def practice
    @list = List.find(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@list)

    qtype = params[:question_type] || :simple
    exclude_ids = params[:exclude_ids] || []
    qnum = params[:number_of_questions] || 10

    lscope = @list.questions

    case qtype
    when :simple
      tscope = lscope.simple
    when :matching
      tscope = lscope.matching
    when :multipart
      tscope = lscope.multipart
    else
      tscope = lscope
    end

    tscope = tscope.where{id.not_eq_all exclude_ids} unless exclude_ids.blank?
    questions = Question.uncached { tscope.random(qnum) }

    # Let's assume only simple questions for now
    @questions = questions.collect do |q|
      {
        :question_id => q.to_param,
        :question_html => q.content_html,
        :answer_choices => q.answer_choices.collect do |ac|
          {
            :answer_choice_id => ac.id,
            :answer_choice_html => ac.content_html
          }
        end
      }
    end

    respond_to do |format|
      format.json do
        headers['Access-Control-Allow-Origin'] = '*'
        render :json => {:list_id => params[:id], :list_name => @list.name, :questions => @questions}
      end
    end
  end
end
