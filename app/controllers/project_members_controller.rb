# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ProjectMembersController < ApplicationController
  before_filter {select_tab(:projects)}
  
  before_filter :get_project, :only => [:search, :create]

  def new
    @action_dialog_title = "Add a member"
    @action_search_path = search_project_project_members_path(params[:project_id])
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  # This is for searching for new members
  def search
    raise SecurityTransgression unless present_user.can_update?(@project)
    
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      @project.is_member?(user)
    end    
    
    @action_partial = 'project_members/create_project_member_form'
    
    respond_to do |format|
      format.js { render :template => 'users/action_search' }
    end
  end

  def create
    raise SecurityTransgression unless present_user.can_update?(@project)

    username = params[:project_member][:username]
    user = User.find_by_username(username)

    if user.nil?
      flash[:alert] = 'User ' + username + ' not found!'
      respond_to do |format|
        format.html { redirect_to project_path(@project) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => {:base => 'Username not found.'}, :status => :unprocessable_entity }
      end
      return
    end

    @project_member = ProjectMember.new(:user => user, :project => @project)
    
    raise SecurityTransgression unless present_user.can_create?(@project_member)

    respond_to do |format|
      if @project_member.save
        ProjectMemberNotifier.project_member_created_email(
          @project_member, present_user)
        format.html { redirect_to project_path(@project) }
        format.js
      else
        flash[:alert] = @project_member.errors.values.to_sentence
        format.html { redirect_to project_path(@project) }
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => @project_member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @project_member = ProjectMember.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@project_member)
    
    respond_to do |format|
      if @project_member.destroy
        @project = @project_member.project
        format.html do
          if @project_member.user == present_user
            redirect_to projects_path
          else
            redirect_to project_path(@project)
          end
        end
        format.js
      else
        format.json { render :json => @project_member.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def make_default
    @project_member = ProjectMember.find(params[:project_member_id])

    raise SecurityTransgression unless present_user.can_update?(@project_member)

    respond_to do |format|
      if @project_member.make_default!
        format.html { redirect_to projects_path }
      else
        format.json { render :json => @project_member.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
protected

  def get_project
    @project = params[:project_id].nil? ? nil : Project.find(params[:project_id])
  end

end
