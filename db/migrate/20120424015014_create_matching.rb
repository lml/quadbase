class CreateMatching < ActiveRecord::Migration
  def self.up
    create_table :matchings do |t|
      t.integer :question_id
      t.integer :choice_id
      t.integer :matched_id
      t.string :content
      t.string :column

      t.timestamps
    end
  end

  def self.down
    drop_table :matchings
  end
end
