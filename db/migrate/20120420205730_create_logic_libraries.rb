class CreateLogicLibraries < ActiveRecord::Migration
  def self.up
    create_table :logic_libraries do |t|
      t.string :name
      t.integer :number
      t.text :summary

      t.timestamps
    end
  end

  def self.down
    drop_table :logic_libraries
  end
end
