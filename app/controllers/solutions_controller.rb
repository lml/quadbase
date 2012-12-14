# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class SolutionsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:index, :show]

  before_filter do @use_columns = true end
  
  layout 'questions'

  before_filter :include_mathjax
  before_filter :include_jquery

  # GET /1/solutions
  def index
    @question = Question.from_param(params[:question_id])

    raise SecurityTransgression unless present_user.can_read?(@question) || 
                                       ((request.remote_ip == '50.116.31.239'))

    @solutions = Vote.order_by_votes(@question.valid_solutions_visible_for(present_user))

    respond_to do |format|
      format.json
      format.html
    end
  end

  # GET /1/solutions/new
  def new
    @question = Question.from_param(params[:question_id])
    @solution = Solution.new
    @solution.question = @question
    @solution.creator = present_user

    raise SecurityTransgression unless present_user.can_create?(@solution)

    respond_to do |format|
      if @solution.save
        format.html { render :action => "edit" }
      else
        @errors = @solution.errors
        format.html { render :action => "index" }
      end
    end
  end

  # GET /solutions/1
  def show
    @solution = Solution.find(params[:id])
    @question = @solution.question

    raise SecurityTransgression unless present_user.can_read?(@solution) || 
                                       ((request.remote_ip == '50.116.31.239'))

    respond_to do |format|
      format.json
      format.html
    end
  end

  # GET /solutions/1/edit
  def edit
    @solution = Solution.find(params[:id])
    @question = @solution.question

    raise SecurityTransgression unless present_user.can_update?(@solution)

    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /solutions/1
  def update
    @solution = Solution.find(params[:id])
    @question = @solution.question

    raise SecurityTransgression unless present_user.can_update?(@solution)

    solution_had_content = @solution.has_content?

    respond_to do |format|
      if @solution.update_attributes(params[:solution])
        if !solution_had_content
          @solution.set_created_at(Time.now)
        end
        flash[:notice] = "Solution " + (solution_had_content ? "updated" : "created") + "."
        format.html { redirect_to(question_solutions_path(@solution.question)) }
      else
        @errors = @solution.errors
        format.html { render :action => "index" }
      end
    end
  end

  # DELETE /solutions/1
  def destroy
    @solution = Solution.find(params[:id])

    raise SecurityTransgression unless present_user.can_destroy?(@solution)

    @solution.destroy

    respond_to do |format|
      flash[:notice] = "Solution deleted."
      format.html { redirect_to(question_solutions_path(@solution.question)) }
      format.js   # destroy.js.erb
    end
  end

end
