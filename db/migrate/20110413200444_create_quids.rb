class CreateQuids < ActiveRecord::Migration
  def self.up
    create_table :quids do |t|
      t.integer :number
      t.integer :version
      t.string :quidable_type
      t.integer :quidable_id

      t.timestamps
    end
  end

  def self.down
    drop_table :quids
  end
end
