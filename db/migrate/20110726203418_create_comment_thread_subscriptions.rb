class CreateCommentThreadSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :comment_thread_subscriptions do |t|
      t.integer :comment_thread_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comment_thread_subscriptions
  end
end
