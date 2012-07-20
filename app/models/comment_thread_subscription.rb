# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class CommentThreadSubscription < ActiveRecord::Base

  belongs_to :comment_thread
  belongs_to :user

  attr_accessible :user, :comment_thread

  validates_uniqueness_of :user_id, :scope => :comment_thread_id

  scope :discussion_subscriptions, joins{comment_thread}.where{comment_thread.commentable_type == "Discussion"}

  def self.discussion_subscriptions_for(user)
    where{user_id == user.id}.discussion_subscriptions
  end

  def mark_all_as_read!
    update_attribute(:unread_count, 0)
    update_discussion_cache
  end

  def mark_all_as_unread!
    update_attribute(:unread_count, comment_thread.comments.count)
    update_discussion_cache
  end

  def add_unread!
    update_attribute(:unread_count, unread_count + 1)
    update_discussion_cache
  end

protected

  def update_discussion_cache
    return unless comment_thread.commentable_type == 'Discussion'
    user.update_attribute(:unread_discussion_count,
      Array.new(CommentThreadSubscription.discussion_subscriptions_for(user)).sum { |ms|
                                                                         ms.unread_count })
  end
end
