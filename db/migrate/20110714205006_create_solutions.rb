class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      t.integer :creator_id
      t.text :content
      t.integer :question_id
      t.integer :modified_by

      t.timestamps
    end
  end

  def self.down
    drop_table :solutions
  end
end
