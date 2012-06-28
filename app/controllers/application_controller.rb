# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ApplicationController < ActionController::Base

  prepend_before_filter :user_not_disabled!,
                        :site_not_in_maintenance!,
                        :authenticate_user!
                        
  around_filter :set_admin_overrides
  
  # Prepend ensures we run those filters before authenticate_admin! no matter what
  # this used to have :protect_beta which provides a basic HTTP auth on the site

  protect_from_forgery
  
  helper_method :user_is_disabled?,
                :site_in_maintenance?,
                :user_is_admin?,
                :present_user,
                :get_error_messages,
                :protect_form,
                :view_dir

  respond_to :html, :js

  unless Quadbase::Application.config.consider_all_requests_local
    rescue_from Exception, :with => :rescue_from_exception
  end
                  
  protected
  
  def set_admin_overrides
    
    overrides_enabled = user_signed_in? && current_user.is_administrator? && !(override_log_level = session[:log_level]).nil?
              
    original_log_level = Rails.logger.level

    if overrides_enabled
      Rails.logger.level = override_log_level.to_i
    end
    
    yield

    if overrides_enabled
      Rails.logger.level = original_log_level
    end
     
  end

  def rescue_from_exception(exception)
    error_page = 500
    send_email = true
    
    case exception
    when SecurityTransgression
      error_page = 403
      send_email = false
    when ActiveRecord::RecordNotFound, 
         ActionController::RoutingError,
         ActionController::UnknownController,
         AbstractController::ActionNotFound
      error_page = 404
      send_email = false
    # when ::ActionController::MissingTemplate,
    #   error_page = 404
    #   send_email = false
    end
    
    render_error_page(error_page)
    DeveloperErrorNotifier.exception_email(exception, request, present_user) if send_email
  end

  # A user can be logged in but later be deauthorized for any number of reasons
  # (essentially locked out).  Going through this helper method gives us a 
  # place to put extra logic
  def user_is_disabled?
    present_user.is_disabled? # Always false for Anonymous
  end
  
  def user_not_disabled!
    !user_is_disabled? || redirect_user_disabled
  end

  def site_in_maintenance?
    WebsiteConfiguration.get_value('in_maintenance')
  end

  def site_not_in_maintenance!
    !site_in_maintenance? || 
    (present_user.is_administrator? && 
    flash.now[:notice] = "Quadbase is currently undergoing maintenance.
                          Non-admin login is disabled.") ||
    (present_user.is_anonymous? &&
    flash.now[:notice] = "Quadbase is currently undergoing maintenance.
                           User login is disabled.") ||
    redirect_maintenance
  end
  
  def user_is_admin?
    user_signed_in? && current_user.is_administrator?
  end

  def authenticate_admin!
    user_is_admin? || redirect_not_admin
  end



  # Like current_user, but for users who aren't logged in returns an 
  # AnonymousUser instead of nil
  def present_user
    current_user || AnonymousUser.instance
  end

  def get_error_messages(object)
    (object.errors.size == 1 ? "Error: " : "Errors: ") +
    object.errors.collect { |e|
      e[0] == :base ? e[1].to_s.chomp(".").gsub(".", " ") :
                      (e[0].to_s + " " + e[1].chomp(".").to_s).gsub(".", " ")
    }.to_sentence.humanize + "."
  end

  def protect_form
    '<script type="text/javascript">
      //<![CDATA[

      window._isDirty = false;

      $(\'input, textarea, select\').not(\'[type="submit"]\').focus(function() {
        window._isDirty = true;
      });

      $(\'input[type="submit"][name="commit"]\').click(function() {
        window._isDirty = false;
      });

      window.onbeforeunload = function () {
        if (window._isDirty) {
          return "Unsaved changes will be lost. Are you sure you want to leave?";
        }
      }

      //]]>
    </script>'.html_safe
  end
  
  def is_id?(value)
    /^\d+$/ === value
  end
  
  # Checks if the value in the params hash with the given key is a possible
  # index, e.g. an non-negative integer.  If so, returns a hash with the key
  # and value.  Otherwise returns nil.  Use this to sanitize inputs.
  def clean_id_param(key)
    is_id?(params[key]) ? {key => params[key]} : nil
  end

  # Used by controllers to specify which tab should be selected, e.g with: 
  #   before_filter {select_tab(:inbox)}
  def select_tab(which)
    @selected_tab = which
  end
  
  # If this method is called in a before_filter, that controller's views will use
  # the standard 2-column layout (small left column, remainder for main column)
  def use_2_column_layout
    @use_2_column_layout = true
  end
  
  def include_mathjax
    @include_mathjax = true
  end
  
  def include_jquery
    @include_jquery = true
  end
  
  def include_jcarousellite
    @include_jcarousellite = true
  end
  
  def include_jcarousel
    @include_jcarousel = true
  end
  
  def include_easing
    @include_easing = true
  end
  
  def render_error_page(status)
    respond_to do |type| 
      type.html { render :template => "errors/#{status}", :layout => 'application', :status => status } 
      type.all  { render :nothing => true, :status => status } 
    end    
  end

  def protect_beta
    return if Rails.env.development? || Rails.env.test?
    
    authenticate_or_request_with_http_basic do |username, password|
      username == "quadbase" && password == "beta"
    end
  end

  def redirect_not_admin
    respond_to do |format|
      format.any do
        flash[:alert] = "You don't have permission to do that!"
        redirect_to root_path
      end
      format.any do
        render :text => "You don't have permission to do that!", :status => :unauthorized, :layout => false
      end
    end
  end
  
  def redirect_user_disabled
    respond_to do |format|
      format.html do
        flash[:alert] = "Your account has been disabled. Please contact the administration if you wish to re-enable it."
        if user_signed_in?
          sign_out current_user
        end
        redirect_to root_path
      end
      format.any do
        render :text => "Your account has been disabled. Please contact the administration if you wish to re-enable it.", :status => :unauthorized, :layout => false
      end
    end
  end

  def redirect_maintenance
    respond_to do |format|
      format.html do
        if user_signed_in?
          sign_out current_user
        end
        redirect_to new_user_session_path
      end
      format.any do
        render :text => "Quadbase is currently undergoing maintenance. User login is disabled.", :status => :unauthorized, :layout => false
      end
    end
  end

  def run_prepublish_error_checks(questions, get_lock=true)
    questions.each do |question|
      if !question.can_be_published_by?(present_user)
        question.errors.add(:base,"You do not have permission to publish this question.")
      else
        question.run_prepublish_error_checks
        get_lock ? question.get_lock!(present_user) : question.check_and_unlock!(present_user)
      end
    end
  end
  
  def combine_base_error_messages(objects)
    combined_message = ""
    
    objects.each do |object|
      combined_message += object.errors[:base].to_sentence if !object.errors[:base].empty?
    end
    
    combined_message    
  end

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        if $1 == 'question'
          return Question.from_param(value)
        else
          return $1.classify.constantize.find(value)
        end
      end
    end
    nil
  end
  
  def get_comment_thread
    commentable = find_commentable
    @comment_thread = commentable.comment_thread
    @commentable = commentable.becomes(Kernel.const_get(@comment_thread.commentable_type))
  end
  
  def view_dir(question)
    question.question_type.underscore.pluralize
  end

end
