class CreateAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :announcements do |t|
      t.integer :user_id
      t.text :subject
      t.text :body
      t.boolean :anonymous
      t.boolean :force

      t.timestamps
    end
  end

  def self.down
    drop_table :announcements
  end
end
