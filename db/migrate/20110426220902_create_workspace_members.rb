class CreateWorkspaceMembers < ActiveRecord::Migration
  def self.up
    create_table :workspace_members do |t|
      t.integer :workspace_id
      t.integer :user_id
      t.boolean :is_default

      t.timestamps
    end
  end

  def self.down
    drop_table :workspace_members
  end
end
