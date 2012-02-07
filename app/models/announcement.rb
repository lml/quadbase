# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Announcement < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :user, :subject

  attr_accessible :subject, :body, :force

  #############################################################################
  # Access control methods
  #############################################################################
    
  def can_be_created_by?(user)
    !user.is_anonymous? && user.is_administrator?
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && user.is_administrator?
  end

end
