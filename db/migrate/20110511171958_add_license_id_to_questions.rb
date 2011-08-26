class AddLicenseIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :license_id, :integer
  end

  def self.down
    remove_column :questions, :license_id
  end
end
