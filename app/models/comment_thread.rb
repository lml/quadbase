# Copyright (c) 2011 Rice University.  All rights reserved.

class CommentThread < ActiveRecord::Base

  belongs_to :commentable, :polymorphic => true

  has_many :comments, :dependent => :destroy
  has_many :comment_thread_subscriptions, :dependent => :destroy

  attr_accessible # none

  def clear!
    # For now, let's keep old comments so we have them in the database in case we need them
    new_thread = CommentThread.new
    new_thread.commentable = commentable
    CommentThread.transaction do
      new_thread.save!
      commentable.comment_thread = new_thread
      commentable.save!
      comment_thread_subscriptions.each do |cts|
        cts.comment_thread = new_thread
        cts.save!
        cts.mark_all_as_read!
      end
      self.commentable = nil
      save!
    end
  end

  def subscription_for(user)
    CommentThreadSubscription.find_by_user_id_and_comment_thread_id(user.id, id)
  end

  def subscribe!(user)
    return true if subscription_for(user)
    comment_thread_subscription = CommentThreadSubscription.new(
      :user => user, :comment_thread => self)
    comment_thread_subscription.save
  end

  def unsubscribe!(user)
    comment_thread_subscription = subscription_for(user)
    return false if !comment_thread_subscription
    comment_thread_subscription.destroy
    commentable.respond_to?(:unsubscribe_callback) ? commentable.unsubscribe_callback : true
  end

  def add_unread_except_for(user)
    comment_thread_subscriptions.each { |cts| cts.add_unread! unless cts.user == user }
  end

  def mark_as_read_for(user)
    return if !subscription_for(user)
    subscription_for(user).mark_all_as_read!
  end

  def mark_as_unread_for(user)
    return if !subscription_for(user)
    subscription_for(user).mark_all_as_unread!
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    user.can_read?(commentable) || user.is_administrator?
  end

  def can_be_updated_by?(user)
    user.can_read?(commentable) || user.is_administrator?
  end

end
