class AddAnnouncementEmailToUserProfile < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :announcement_email, :boolean
  end

  def self.down
    remove_column :user_profiles, :announcement_email
  end
end
