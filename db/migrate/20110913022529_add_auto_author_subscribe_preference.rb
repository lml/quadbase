class AddAutoAuthorSubscribePreference < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :auto_author_subscribe, :boolean, :default => true
  end

  def self.down
    remove_column :user_profiles, :auto_author_subscribe
  end
end
