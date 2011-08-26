# Copyright (c) 2011 Rice University.  All rights reserved.

class ProjectMembersController < ApplicationController
  before_filter {select_tab(:projects)}

  def create
    @project = params[:project_id].nil? ? nil : Project.find(params[:project_id])

    raise SecurityTransgression unless present_user.can_update?(@project)

    user = User.find_by_username(params[:username]) # Rails should escape these automatically

    if user.nil?
      flash[:alert] = 'User ' + params[:username] + ' not found!'
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
        format.html { redirect_to project_path(@project) }
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

end
