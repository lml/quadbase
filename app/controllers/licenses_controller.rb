# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class LicensesController < AdminController
  skip_before_filter :authenticate_user!, :authenticate_admin!, :only => :show
  
  before_filter {select_tab(:admin)}

  def index
    respond_with(@licenses = License.all)
  end

  def show
    @license = License.find(params[:id])
    respond_with(@license)
  end

  def new
    respond_with(@license = License.new)
  end

  def edit
    @license = License.find(params[:id])
    respond_with(@license)
  end

  def create
    @license = License.new(params[:license])
    @license.save
    respond_with(@license)
  end

  def update
    @license = License.find(params[:id])
    @license.update_attributes(params[:license])
    respond_with(@license)
  end

  def destroy
    @license = License.find(params[:id])
    @license.destroy
    respond_with(@license)
  end

  def make_default
    @license = License.find(params[:selected_license])
    @license.make_default!
    flash[:notice] = "Changes saved."
    redirect_to licenses_path
  end
end
