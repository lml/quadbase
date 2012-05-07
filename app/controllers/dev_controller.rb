# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details. 

class DevController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter :check_dev_env

  def toolbox
  end
  
  def reset_time
    Timecop.return
  end

  def time_travel
    Timecop.return
    Timecop.travel(Chronic.parse(params[:new_time]))
  end
  
  def freeze_time
    Timecop.return
    Timecop.freeze(params[:offset_days].to_i.days.since(Time.now))
  end
  

protected

  def check_dev_env
    raise SecurityTransgression unless Rails.env.development?
  end


end
