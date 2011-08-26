class CreateDeputizations < ActiveRecord::Migration
  def self.up
    create_table :deputizations do |t|
      t.integer :deputizer_id
      t.integer :deputy_id

      t.timestamps
    end
  end

  def self.down
    drop_table :deputizations
  end
end
