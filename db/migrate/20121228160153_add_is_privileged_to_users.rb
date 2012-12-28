class AddIsPrivilegedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_privileged, :boolean, :default => false
  end
end
