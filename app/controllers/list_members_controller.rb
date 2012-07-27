# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListMembersController < ApplicationController
  before_filter {select_tab(:lists)}
  
  before_filter :get_list, :only => [:search, :create]

  def new
    @action_dialog_title = "Add a member"
    @action_search_path = search_list_list_members_path(params[:list_id])
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  # This is for searching for new members
  def search
    raise SecurityTransgression unless present_user.can_update?(@list)
    
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      @list.is_member?(user)
    end    
    
    @action_partial = 'list_members/create_list_member_form'
    
    respond_to do |format|
      format.js { render :template => 'users/action_search' }
    end
  end

  def create
    raise SecurityTransgression unless present_user.can_update?(@list)

    username = params[:list_member][:username]
    user = User.find_by_username(username)

    if user.nil?
      flash[:alert] = 'User ' + username + ' not found!'
      respond_to do |format|
        format.html { redirect_to list_path(@list) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => {:base => 'Username not found.'}, :status => :unprocessable_entity }
      end
      return
    end

    @list_member = ListMember.new(:user => user, :list => @list)
    
    raise SecurityTransgression unless present_user.can_create?(@list_member)

    respond_to do |format|
      if @list_member.save
        ListMemberNotifier.list_member_created_email(
          @list_member, present_user)
        format.html { redirect_to list_path(@list) }
        format.js
      else
        flash[:alert] = @list_member.errors.values.to_sentence
        format.html { redirect_to list_path(@list) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => @list_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @list_member = ListMember.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@list_member)
    
    respond_to do |format|
      if @list_member.destroy
        @list = @list_member.list
        format.html do
          if @list_member.user == present_user
            redirect_to lists_path
          else
            redirect_to list_path(@list)
          end
        end
        format.js
      else
        format.json { render :json => @list_member.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def make_default
    @list_member = ListMember.find(params[:list_member_id])

    raise SecurityTransgression unless present_user.can_update?(@list_member)

    respond_to do |format|
      if @list_member.make_default!
        format.html { redirect_to lists_path }
      else
        format.json { render :json => @list_member.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
protected

  def get_list
    @list = params[:list_id].nil? ? nil : List.find(params[:list_id])
  end

end
