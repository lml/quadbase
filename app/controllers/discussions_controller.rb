# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class DiscussionsController < ApplicationController

  before_filter :include_jquery
  
  before_filter :get_discussion, :only => [:add_recipient, :search_recipients, :leave]

  # GET /discussions/1
  def show
    @discussion = Discussion.find(params[:id])

    raise SecurityTransgression unless present_user.can_read?(@discussion)

    @discussion.comment_thread.mark_as_read_for(present_user)
    present_user.reload

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /discussions/new
  def new
    @discussion = Discussion.new

    raise SecurityTransgression unless present_user.can_create?(@discussion)

    respond_to do |format|
      if @discussion.save
        @discussion.comment_thread.subscribe!(present_user)
        format.html { redirect_to @discussion }
      else
        format.html { redirect_to inbox_path }
      end
    end
  end

  # PUT /discussions/1
  def update
    @discussion = Discussion.find(params[:id])

    raise SecurityTransgression unless present_user.can_create?(@discussion)

    @discussion.subject = params[:message][:subject]

    @comment = Comment.new
    @comment.message = params[:message][:body]
    @comment.comment_thread = @discussion.comment_thread
    @comment.creator = present_user

    raise SecurityTransgression unless present_user.can_create?(@comment)

    respond_to do |format|
      if @discussion.save && @comment.save
        @discussion.comment_thread.add_unread_except_for(present_user)
        flash[:notice] = 'Message was sent successfully.'
        format.html { redirect_to @discussion }
      else
        format.html { redirect_to @discussion }
      end
    end
  end
  
  def leave
    @discussion.comment_thread.unsubscribe!(present_user)    
  end

  def new_recipient
    @action_dialog_title = "Add a recipient"
    @action_search_path = discussion_search_recipients_path(params[:discussion_id])
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  def search_recipients
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      @discussion.has_recipient?(user)
    end    

    @action_partial = 'discussions/create_recipient_form'

    respond_to do |format|
     format.js { render :template => 'users/action_search' }
    end
  end

  # POST /discussions/1/add_recipient
  def add_recipient
    raise SecurityTransgression unless present_user.can_update?(@discussion)
    
    @recipient = User.find_by_username(params[:username])

    if @recipient.nil?
      flash[:alert] = 'User ' + params[:username] + ' not found!'
      respond_to do |format|
        format.html { redirect_to @discussion }
        format.js { render :template => 'shared/display_flash' }
      end
      return
    end

    respond_to do |format|
      if @discussion.comment_thread.subscribe!(@recipient)
        @discussion.comment_thread.mark_as_unread_for(@recipient)
        format.html { redirect_to @discussion }
        format.js
      else
        flash[:alert] = @discussion.comment_thread.errors.values.to_sentence
        format.html { redirect_to @discussion }
        format.js { render :template => 'shared/display_flash' }
      end
    end
  end
  
protected

  def get_discussion
    @discussion = Discussion.find(params[:discussion_id])
  end

end
