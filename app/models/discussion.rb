# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Discussion < ActiveRecord::Base

  has_one :comment_thread, :as => :commentable, :dependent => :destroy
  before_validation :build_comment_thread, :on => :create
  validates_presence_of :comment_thread
  validate :subject_not_changed

  attr_accessor :body

  attr_accessible #none

  def self.discussions_for(user)
    CommentThreadSubscription.discussion_subscriptions_for(user).collect { |cts| cts.comment_thread.commentable }
  end

  def subject
    s = read_attribute(:subject)
    s.blank? ? "[No Subject]" : s
  end

  def recipients
    comment_thread.comment_thread_subscriptions.collect { |cts| cts.user }
  end
  
  def has_recipient?(user)
    recipients.any?{|r| r == user}
  end

  def unsubscribe_callback
    destroy if comment_thread.reload.comment_thread_subscriptions.blank?
    true
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && (comment_thread.comment_thread_subscriptions.detect { |cts| cts.user == user } || user.is_administrator?)
  end

  def can_be_created_by?(user)
    !user.is_anonymous?
  end

  def can_be_updated_by?(user)
    !user.is_anonymous? && (comment_thread.comment_thread_subscriptions.detect { |cts| cts.user == user } || user.is_administrator?)
  end

  def can_be_joined_by?(user)
    !user.is_anonymous? &&
      !comment_thread.comment_thread_subscriptions.detect { |cts| cts.user == user }
  end
  
protected

  def subject_not_changed
    return if !subject_changed? || comment_thread.comments.blank?
    errors.add(:base, "You can't change a discussion's subject after it is sent.")
    false
  end

end
