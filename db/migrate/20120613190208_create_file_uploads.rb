class CreateFileUploads < ActiveRecord::Migration
  def self.up
    create_table :file_uploads do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :file_uploads
  end
end
