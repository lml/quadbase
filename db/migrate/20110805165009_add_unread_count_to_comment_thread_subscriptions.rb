class AddUnreadCountToCommentThreadSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :comment_thread_subscriptions, :unread_count, :integer, :default => 0
  end

  def self.down
    remove_column :comment_thread_subscriptions, :unread_count
  end
end
