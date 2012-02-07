# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class DeputizationsController < ApplicationController
  
  # It should be relatively easy to add html responses if needed  
  respond_to :js
  
  def new
    @action_dialog_title = "Add a deputy"
    @action_search_path = search_deputizations_path
    
    respond_to do |format|
      format.js { render :template => 'users/action_new' }
    end
  end
  
  # This is for searching for new deputies
  def search
    @selected_type = params[:selected_type]
    @text_query = params[:text_query]
    @users = User.search(@selected_type, @text_query)

    @users.reject! do |user| 
      !present_user.can_create?(Deputization.new(:deputizer_id => current_user.id, 
                                                 :deputy_id => user.id))
    end    
    
    @action_partial = 'deputizations/create_deputization_form'
    
    respond_to do |format|
      format.js { render :template => 'users/action_search' }
    end
  end

  def create
    @deputization = Deputization.new(params[:deputization])
    
    raise SecurityTransgression unless present_user.can_create?(@deputization)
    
    respond_to do |format|
      if @deputization.save
        format.js
      else
        flash[:alert] = @deputization.errors.values.to_sentence
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => @deputization.errors, :status => :unprocessable_entity }
      end      
    end
  end

  def destroy
    @deputization = Deputization.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@deputization)
    @deputization.destroy
  end

end
