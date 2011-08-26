# Copyright (c) 2011 Rice University.  All rights reserved.

class AdminController < ApplicationController
  before_filter :authenticate_admin! # This will always run after authenticate_user!
  
  def index
  end
  
  def become
    raise SecurityTransgression unless current_user.is_administrator?
    sign_in(:user, User.find(params[:user_id]))
    redirect_to root_path
  end

end
