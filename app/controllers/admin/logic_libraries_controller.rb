class Admin::LogicLibrariesController < ApplicationController
  
  before_filter :authenticate_admin!
  
  def index
    @logic_libraries = LogicLibrary.ordered
  end

  def show
    @logic_library = LogicLibrary.find(params[:id])
  end

  def new
    @logic_library = LogicLibrary.new
  end

  def edit
    @logic_library = LogicLibrary.find(params[:id])
  end

  def create
    @logic_library = LogicLibrary.new(params[:logic_library])

    respond_to do |format|
      if @logic_library.save
        format.html { redirect_to([:admin, @logic_library], :notice => 'Logic library was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @logic_library = LogicLibrary.find(params[:id])

    respond_to do |format|
      if @logic_library.update_attributes(params[:logic_library])
        format.html { redirect_to([:admin, @logic_library], :notice => 'Logic library was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @logic_library = LogicLibrary.find(params[:id])
    @logic_library.destroy

    respond_to do |format|
      format.html { redirect_to(admin_logic_libraries_url) }
    end
  end
  
  def sort
    begin 
      LogicLibrary.sort!(params['sortable_item'])
    rescue Exception => invalid
      flash[:alert] = "An error occurred: #{invalid.message}"
    end
  end
  
end
