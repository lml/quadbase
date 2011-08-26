class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :comment_thread_id
      t.text :message
      t.integer :creator_id
      t.boolean :is_log

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
