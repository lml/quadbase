# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class AnnouncementNotifier < QuadbaseMailer

  def announcement_email(announcement)
    mail(:from => "noreply@quadbase.org",
         :bcc => User.active_users \
               .reject { |a| !announcement.force && a.user_profile.announcement_email } \
               .collect { |a| a.email },
         :subject => announcement.subject,
         :body => announcement.body).deliver
  end

end
