# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class AdminController < ApplicationController
  before_filter :authenticate_admin! # This will always run after authenticate_user!
  
  def index
  end
  
  def become
    raise SecurityTransgression unless current_user.is_administrator?
    sign_in(:user, User.find(params[:user_id]))
    redirect_to root_path
  end
  
  def set_log_level
    session[:log_level] = params[:log_level]
    redirect_to admin_path
  end

end
