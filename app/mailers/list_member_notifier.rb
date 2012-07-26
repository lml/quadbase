# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListMemberNotifier < QuadbaseMailer

  def list_member_created_email(list_member, user)
    
    setup_variables(list_member, user)

    return if !@member.user_profile.list_member_email

    mail(:to => @member.email,
         :subject => "You have been added to " + 
                     @list.name + " by " + user.full_name).deliver
  end
  
private

  def setup_variables(list_member, user)
    @user = user
    @member = list_member.user
    @list = list_member.list 
  end
  
end
