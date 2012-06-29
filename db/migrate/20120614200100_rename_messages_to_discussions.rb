class RenameMessagesToDiscussions < ActiveRecord::Migration
  def up
    rename_table :messages, :discussions
    rename_column :users, :unread_message_count, :unread_discussion_count
  end

  def down
    rename_table :discussions, :messages
    rename_column :users, :unread_discussion_count, :unread_message_count
  end
end
