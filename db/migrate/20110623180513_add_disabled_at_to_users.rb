class AddDisabledAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :disabled_at, :datetime
  end

  def self.down
    remove_column :users, :disabled_at
  end
end
