class DropAnonymousFromAnnouncements < ActiveRecord::Migration
  def self.up
    remove_column :announcements, :anonymous
  end

  def self.down
    add_column :announcements, :anonymous, :boolean
  end
end
