class CreateLogics < ActiveRecord::Migration
  def self.up
    create_table :logics do |t|
      t.text :code
      t.string :variables
      t.string :logicable_type
      t.integer :logicable_id

      t.timestamps
    end
  end

  def self.down
    drop_table :logics
  end
end
