# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class CommentThreadSubscription < ActiveRecord::Base

  belongs_to :comment_thread
  belongs_to :user

  attr_accessible :user, :comment_thread

  validates_uniqueness_of :user_id, :scope => :comment_thread_id

  scope :message_subscriptions, joins{comment_thread}.where{comment_thread.commentable_type == "Message"}

  def self.message_subscriptions_for(user)
    where{user_id == user.id}.message_subscriptions
  end

  def mark_all_as_read!
    update_attribute(:unread_count, 0)
    update_message_cache
  end

  def mark_all_as_unread!
    update_attribute(:unread_count, comment_thread.comments.count)
    update_message_cache
  end

  def add_unread!
    update_attribute(:unread_count, unread_count + 1)
    update_message_cache
  end

protected

  def update_message_cache
    return unless comment_thread.commentable_type == 'Message'
    user.update_attribute(:unread_message_count,
      Array.new(CommentThreadSubscription.message_subscriptions_for(user)).sum { |ms|
                                                                             ms.unread_count })
  end

end
