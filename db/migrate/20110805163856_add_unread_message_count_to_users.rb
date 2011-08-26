class AddUnreadMessageCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unread_message_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :unread_message_count
  end
end
