# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Admin::LogicLibraryVersionsController < ApplicationController
  
  before_filter :authenticate_admin!
  before_filter :get_logic_library, :only => [:new, :create]
  
  def show
    @logic_library_version = LogicLibraryVersion.find(params[:id])
  end

  def new
   @logic_library_version = LogicLibraryVersion.new(:logic_library_id => @logic_library.id)
  end

  def edit
    @logic_library_version = LogicLibraryVersion.find(params[:id])
  end

  def create
    @logic_library_version = LogicLibraryVersion.new(params[:logic_library_version])
    @logic_library_version.logic_library = @logic_library

    respond_to do |format|
      if @logic_library_version.save
        format.html { redirect_to([:admin, @logic_library_version], :notice => 'Logic library version was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @logic_library_version = LogicLibraryVersion.find(params[:id])

    respond_to do |format|
      if @logic_library_version.update_attributes(params[:logic_library_version])
        format.html { redirect_to([:admin, @logic_library_version], :notice => 'Logic library version was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @logic_library_version = LogicLibraryVersion.find(params[:id])

    respond_to do |format|
      if @logic_library_version.destroy
        format.html { redirect_to([:admin, @logic_library_version.logic_library]) }
      else
        @errors = @logic_library_version.errors
        format.html { render :action => 'show' }
      end
    end
  end
  
  protected
  
  def get_logic_library
    @logic_library = LogicLibrary.find(params[:logic_library_id])
  end

  
end
