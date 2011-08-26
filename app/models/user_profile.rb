# Copyright (c) 2011 Rice University.  All rights reserved.

class UserProfile < ActiveRecord::Base

  belongs_to :user

  attr_accessible :project_member_email, :role_request_email, :announcement_email, :user

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
