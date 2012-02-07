# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class DeveloperErrorNotifier < QuadbaseMailer
  
  def exception_email(exception, user, full_trace = false)
    setup_variables(exception, user, full_trace)

    mail(:to => User.active_administrators.collect { |a| a.email },
         :subject => "User " + user.username + " encountered an Exception").deliver
  end

  private

  def setup_variables(exception, user, full_trace)
    @user = user
    @exception = exception
    @backtrace = full_trace ?
                exception.backtrace :
                Rails.backtrace_cleaner.clean(exception.backtrace)
  end
  
end
