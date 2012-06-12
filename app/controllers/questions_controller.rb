# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionsController < ApplicationController
  include ActionView::Helpers::TextHelper

  skip_before_filter :authenticate_user!, :only => [:index, :get_started, :show, :search, :tagged, :quickview]

  before_filter :include_mathjax, :only => [:index, :show, :edit, :search, :show_part, :update, :get_started]
  before_filter :include_jquery

  before_filter {select_tab(:write)}
  before_filter :except => [:index, :new, :get_started, :search] do @use_columns = true end

  before_filter {@include_autocomplete=true}
    
  autocomplete :tag, :name, :class_name => 'ActsAsTaggableOn::Tag'
  
  def index
    @where ||= 'Published Questions'
  end

  def show
    @question = Question.from_param(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@question)
    
    start_time = Time.now if logger.info?
    
    @question.variate!(QuestionVariator.new(params[:seed]))
    
    logger.info {"Variated question #{@question.to_param} with seed " +
                 "#{params[:seed] || '[unset]'}, duration = #{Time.now-start_time}"}
          
    respond_to do |format|
      format.json
      format.html 
      format.qti { 
        render :template => case params[:version] 
                            when "1.2", nil
                              "#{view_dir(@question)}/show.1p2"
                            else
                              raise ActionController::UnknownAction
                            end
      }
    end
  end

  def history
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_read?(@question)
    respond_with(@questions = Question.published_with_number(@question.number))
  end

  def new
  end
  
  def get_started
  end
  
  def create_simple
    create(SimpleQuestion.new)
  end
  
  def create_multipart
    create(MultipartQuestion.new)
  end
  
  def edit
    @question = Question.from_param(params[:id])
    raise SecurityTransgression unless present_user.can_update?(@question)
    if !@question.get_lock!(present_user)
      flash[:alert] = @question.errors[:base]
      redirect_to(question_path(@question))
      return
    end
    respond_with(@question)
  end

  
  # We can't use the normal respond_with here b/c the STI we're using confuses it.  
  # Rails tries to render simple_questions/edit when there are update errors, but
  # we just want it to go to the questions view.
  def update
    @question = Question.from_param(params[:id])

    raise SecurityTransgression unless present_user.can_update?(@question)
    if (@no_lock = !@question.check_and_unlock!(present_user))
      flash[:alert] = @question.errors[:base]
      respond_to do |format|
        format.html { redirect_to(question_path(@question)) }
        format.js
      end
      return
    end

    respond_to do |format|  
       if (@updated = @question.update_attributes(params[:question]))
        flash[:notice] = "Your draft has been saved.
                          Until you publish this draft, please remember that only members of " +
                          @question.project.name +
                          " will be able to see it."
        format.html { redirect_to question_path(@question) }
       else
        format.html { render 'questions/edit' }
       end
     end
  end

  def quickview
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_read?(@question)

    @show_credit = true

    respond_to do |format|
      format.html { redirect_to question_path(@question) }
      format.js
    end
  end

  def preview
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_read?(@question)

    @question.attributes = params[:question]
    @show_credit = true

    Question.transaction do
      respond_to do |format|
        if @question.save
          @question.variate!(QuestionVariator.new)
          format.js
        else
          format.js
        end
      end
      raise ActiveRecord::Rollback
    end
  end
  
  def show_part
    @multipart_question = Question.from_param(params[:question_id])
    
    parts = @multipart_question.child_question_parts
    raise SecurityTransgression unless parts.length >= params[:part_id].to_i
    
    @question = parts[params[:part_id].to_i-1].child_question
    
    raise SecurityTransgression unless present_user.can_read?(@question)
    
    
    respond_to do |format|
      format.html { render 'questions/show' }
    end
  end
  
  def tags
    @tags = Question.tag_counts_on(:tags)
  end
  
  def add_tags
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_tag?(@question)
    
    incoming_tags = params[:tags].split(",").collect{|t| t.strip}.delete_if{|t| t.blank?}
    
    if incoming_tags.empty?
    elsif tags_fail_regex?(incoming_tags)
      flash[:alert] = "Tags can only contain letters, numbers, spaces, hyphens, and apostrophes.  Multiple tags should be separated by commas."
    else
      tags = @question.tag_list.concat(incoming_tags).join(", ")
      @question.update_attribute(:tag_list, tags)      
    end   
    
    respond_to do |format|
      format.js { render :template => 'questions/tags_action' }
    end 
  end
  
  def remove_tag
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_tag?(@question)

    target_tag = params[:tag].gsub("_"," ")

    if !target_tag.blank? && !tags_fail_regex?(target_tag)
      updated_tag_list = @question.tag_list.reject{|t| target_tag == t}
      @question.update_attribute(:tag_list, updated_tag_list)
    end
    
    respond_to do |format|
      @in_remove_state = true
      format.js { render :template => 'questions/tags_action' }
    end
  end
  
  def tagged
    @tags = params[:tags].gsub("_"," ").split("+")
    @per_page = params[:per_page] || 20
    
    if tags_fail_regex?(@tags)
      @questions = []
      flash[:alert] = "The provided tags contain invalid characters."
    else
      @questions = Question.tagged_with(@tags)
                           .reject{|q| (q.is_published? && !q.is_latest?) || 
                                        !present_user.can_read?(q)}
                           .paginate(:page => params[:page], :per_page => @per_page)
    end
  end

  def destroy
    @question = Question.from_param(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@question)
    @question.destroy
    flash[:notice] = 'Draft deleted.'
    respond_with(@question) do |format|
      format.html { redirect_to questions_path }
    end
  end

  def preview_publish
    @questions = Question.find(params[:question_ids])
    run_prepublish_error_checks(@questions)
    respond_with(@questions)
  end
  
  def publish
    @questions = Question.find(params[:question_ids])
    
    @questions.each { |q|
      raise SecurityTransgression unless q.can_be_published_by?(present_user)
    }

    run_prepublish_error_checks(@questions, false)
    error_message = combine_base_error_messages(@questions)
    
    if !error_message.blank?
      respond_to do |format|
        format.html {
          flash[:alert] = error_message
          redirect_to(publish_questions_path(:question_ids => @questions.collect{|q| q.id})) && return
        }
        format.any(:json,:xml) { raise NotYetImplemented }
      end
    end
    
    if params[:agreement_checkbox]
      @questions.each { |q|
        q.publish!(present_user)
      }
      
      respond_with(@questions) do |format|
        format.html { 
          redirect_to @questions.size == 1 ? 
                      question_path(@questions.first) :
                      questions_path
        }
      end
    else
      flash[:alert] = "You must accept the license agreement in order to publish " + 
                      ((@questions.size == 1) ? "this question." : "these questions.")
      respond_with(@questions) do |format|
        format.html { redirect_to :back }
      end
    end
  end
  
  def source
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless @question.can_be_read_by?(present_user)
    respond_with(@question)
  end
  
  def new_version
    @source_question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless @source_question.can_be_new_versioned_by?(present_user)
    
    begin
      @question = @source_question.new_version!(present_user)
      respond_to do |format|
        format.html { redirect_to edit_question_path(@question) }
      end
    rescue ActiveRecord::RecordInvalid => invalid
      logger.error {"An error occurred when deriving a question: #{invalid.message}"}
      flash[:alert] = "We could not create a derived question as requested."
      respond_to do |format|
        format.html { redirect_to question_path(@source_question) }
      end      
    end
  end

  def derivation_dialog
    @question = Question.from_param(params[:question_id])

    raise SecurityTransgression unless @question.can_be_derived_by?(present_user)

    @projects = current_user.projects

    respond_to do |format|
      format.js
    end     
  end

  def new_derivation
    @source_question = Question.from_param(params[:question_id])
    project = Project.find(params[:project].keys.first)
    edit_now = params[:edit] == "now"
    raise SecurityTransgression unless (@source_question.can_be_derived_by?(present_user) &&
      (!project.nil? && project.can_be_updated_by?(present_user)))
    
    begin
      @question = @source_question.new_derivation!(present_user, project)
      flash[:notice] = "Derived question created."
      respond_to do |format|
        if edit_now
          format.html { redirect_to edit_question_path(@question) }
          format.js { render 'questions/edit_now' }
        else
          format.html { redirect_to question_path(@source_question) }
          format.js { render 'questions/edit_later' }
        end
      end

    rescue ActiveRecord::RecordInvalid => invalid
      logger.error {"An error occurred when deriving a question: #{invalid.message}"}
      flash[:alert] = "We could not create a derived question as requested."
      respond_to do |format|
        format.html { redirect_to question_path(@source_question) }
        format.js { render 'shared/display_flash' }
      end
    end
    false
  end

  # Originally, the license was set with the other attributes on the 
  # new/edit/update pages.  However, we decided to break that out into a 
  # separate page b/c it wasn't super critical (and because we are going to 
  # start questions with a default license.)  These methods support those pages.
  
  def edit_license
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_update?(@question)
    respond_with(@question)
  end
  
  def update_license
    @question = Question.from_param(params[:question_id])
    raise SecurityTransgression unless present_user.can_update?(@question)

    @question.license = License.find(params[:question][:license_id])
    
    respond_to do |format|
      if @question.save
        format.html { redirect_to question_path(@question) }
      else
        format.html { render 'questions/edit_license' }
      end
    end
  end

  def search
    @type = params[:type]
    @location = params[:location]
    @part = params[:part]
    @query = params[:query]
    @exclude_type = params[:exclude_type]
    @per_page = params[:per_page]
    @questions = Question.search(@type, @location, @part,
                                 @query, present_user, @exclude_type)
    respond_to do |format|
      format.html do
        @questions = @questions.paginate(:page => params[:page], :per_page => @per_page)
      end
      format.js
    end
  end
  
protected

  def create(question) 
    @question = question
    raise SecurityTransgression unless present_user.can_create?(@question)
                    
    begin
      @question.create!(current_user)
    
      respond_to do |format|
        format.html { redirect_to edit_question_path(@question) }
      end
    rescue ActiveRecord::RecordInvalid => invalid
      logger.error {"An error occurred when creating a question: #{invalid.message}"}
    
      respond_to do |format|
        format.html {   
          begin
            redirect_to :back
          rescue ActionController::RedirectBackError
            redirect_to root_path 
          end
        }
      end      
    end
  end
  
  def tags_fail_regex?(tags)
    tags = [tags].flatten
    tags.any?{|tag| (tag =~ /^[A-Za-z\d\-' ]+$/).nil?}
  end

end
