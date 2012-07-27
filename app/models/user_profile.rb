# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class UserProfile < ActiveRecord::Base

  belongs_to :user

  attr_accessible :list_member_email, :role_request_email, 
                  :announcement_email, :auto_author_subscribe, :user

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && user == self.user
  end
  
  def can_be_updated_by?(user)
    !user.is_anonymous? && user == self.user
  end

end
