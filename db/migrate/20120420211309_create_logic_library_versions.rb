class CreateLogicLibraryVersions < ActiveRecord::Migration
  def self.up
    create_table :logic_library_versions do |t|
      t.integer :logic_library_id
      t.integer :version
      t.text :code
      t.text :minified_code
      t.boolean :deprecated

      t.timestamps
    end
  end

  def self.down
    drop_table :logic_library_versions
  end
end
