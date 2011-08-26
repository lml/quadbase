class CreateWebsiteConfigurations < ActiveRecord::Migration
  def self.up
    create_table :website_configurations do |t|
      t.string :name
      t.string :value
      t.string :value_type

      t.timestamps
    end
  end

  def self.down
    drop_table :website_configurations
  end
end
