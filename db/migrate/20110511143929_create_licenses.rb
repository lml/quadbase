class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.string :short_name
      t.string :long_name
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :licenses
  end
end
