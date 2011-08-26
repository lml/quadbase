# Copyright (c) 2011 Rice University.  All rights reserved.

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
