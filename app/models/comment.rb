# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Comment < ActiveRecord::Base

  belongs_to :comment_thread
  belongs_to :creator, :class_name => "User"

  has_many :votes, :as => :votable, :dependent => :destroy

  validates_presence_of :comment_thread, :creator

  attr_accessible :message

  def is_modified?
    updated_at != created_at
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    comment_thread.can_be_read_by?(user)
  end

  def can_be_created_by?(user)
    comment_thread.can_be_updated_by?(user)
  end

  def can_be_updated_by?(user)
    !user.is_anonymous? && user == creator && (comment_thread.commentable_type != 'Discussion' || comment_thread.comments.last == self)
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && (user == creator || user.is_administrator?) &&
      (comment_thread.commentable_type != 'Discussion' || comment_thread.comments.last == self)
  end

  def can_be_voted_on_by?(user)
    can_be_read_by?(user) && user != creator && comment_thread.commentable_type != 'Discussion'
  end

end
