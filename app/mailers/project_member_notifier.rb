# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ProjectMemberNotifier < QuadbaseMailer

  def project_member_created_email(project_member, user)
    
    setup_variables(project_member, user)

    return if !@member.user_profile.project_member_email

    mail(:to => @member.email,
         :subject => "You have been added to " + 
                     @project.name + " by " + user.full_name).deliver
  end
  
private

  def setup_variables(project_member, user)
    @user = user
    @member = project_member.user
    @project = project_member.project 
  end
  
end
