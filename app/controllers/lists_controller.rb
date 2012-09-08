# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListsController < ApplicationController

  before_filter :include_jquery, :only => [:show, :index]
  before_filter :include_mathjax, :only => :show

  before_filter :use_2_column_layout
  before_filter {select_tab(:lists)}

  helper :questions

  def index
    respond_with(@list_members = current_user.list_members)
  end

  def show
    @list = List.find(params[:id])
    raise SecurityTransgression unless present_user.can_read?(@list)
    @target_lists = current_user.lists.reject { |w| w == @list}
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
  
end
