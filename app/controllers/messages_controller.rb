# Copyright (c) 2011 Rice University.  All rights reserved.

class MessagesController < ApplicationController

  before_filter :include_jquery
  
  before_filter :get_message, :only => [:add_recipient, :search_recipients]

  # GET /messages/1
  def show
    @message = Message.find(params[:id])

    raise SecurityTransgression unless present_user.can_read?(@message)

    @message.comment_thread.mark_as_read_for(present_user)
    present_user.reload

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /messages/new
  def new
    @message = Message.new

    raise SecurityTransgression unless present_user.can_create?(@message)

    respond_to do |format|
      if @message.save
        @message.comment_thread.subscribe!(present_user)
        format.html { redirect_to @message }
      else
        format.html { redirect_to inbox_path }
      end
    end
  end

  # PUT /messages/1
  def update
    @message = Message.find(params[:id])

    raise SecurityTransgression unless present_user.can_create?(@message)

    @message.subject = params[:message][:subject]

    @comment = Comment.new
    @comment.message = params[:message][:body]
    @comment.comment_thread = @message.comment_thread
    @comment.creator = present_user

    raise SecurityTransgression unless present_user.can_create?(@comment)

    respond_to do |format|
      if @message.save && @comment.save
        @message.comment_thread.add_unread_except_for(present_user)
        flash[:notice] = 'Message was sent successfully.'
        format.html { redirect_to @message }
      else
        format.html { redirect_to @message }
      end
    end
  end

  def new_recipient
    @action_dialog_title = "Add a recipient"
    @action_search_path = message_search_recipients_path(params[:message_id])
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  def search_recipients
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      @message.has_recipient?(user)
    end    

    @action_partial = 'messages/create_recipient_form'

    respond_to do |format|
     format.js { render :template => 'users/action_search' }
    end
  end

  # POST /messages/1/add_recipient
  def add_recipient
    raise SecurityTransgression unless present_user.can_update?(@message)
    
    @recipient = User.find_by_username(params[:username])

    if @recipient.nil?
      flash[:alert] = 'User ' + params[:username] + ' not found!'
      respond_to do |format|
        format.html { redirect_to @message }
        format.js { render :template => 'shared/display_flash' }
      end
      return
    end

    respond_to do |format|
      if @message.comment_thread.subscribe!(@recipient)
        @message.comment_thread.mark_as_unread_for(@recipient)
        format.html { redirect_to @message }
        format.js
      else
        flash[:alert] = @message.comment_thread.errors.values.to_sentence
        format.html { redirect_to @message }
        format.js { render :template => 'shared/display_flash' }
      end
    end
  end
  
protected

  def get_message
    @message = Message.find(params[:message_id])
  end

end
