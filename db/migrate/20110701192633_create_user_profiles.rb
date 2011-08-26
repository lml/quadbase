class CreateUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :user_profiles do |t|
      t.integer :user_id
      t.boolean :workspace_member_email, :default => true
      t.boolean :role_request_email, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :user_profiles
  end
end
