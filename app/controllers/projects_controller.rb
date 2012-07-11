# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ProjectsController < ApplicationController

  before_filter :include_jquery, :only => [:show, :index]
  before_filter :include_mathjax, :only => :show

  before_filter :use_2_column_layout
  before_filter {select_tab(:projects)}

  helper :questions

  def index
    respond_with(@project_members = current_user.project_members)
  end

  def show
    @project = Project.find(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@project)
    @target_projects = current_user.projects.reject { |w| w == @project}
    @all_projects = current_user.projects
    respond_with(@project)
  end

  def new
    respond_with(@project = Project.new)
  end

  def edit
    @project = Project.find(params[:id])
    raise SecurityTransgression unless present_user.can_update?(@project)
    respond_with(@project)
  end

  def create
    @project = Project.new(params[:project])
    raise SecurityTransgression unless present_user.can_create?(@project)
    
    Project.transaction do
      @project.save
      @project.add_member!(current_user)
    end
    respond_with(@project)
  end

  def update
    @project = Project.find(params[:id])
    raise SecurityTransgression unless present_user.can_update?(@project)
    @project.update_attributes(params[:project])
    respond_with(@project)
  end

  def destroy
    @project = Project.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@project)
    @project.destroy
    respond_with(@project)
  end
  
end
