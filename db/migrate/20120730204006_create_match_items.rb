class CreateMatchItems < ActiveRecord::Migration
  def change
    create_table :match_items do |t|
      t.integer :question_id
      t.integer :match_number
      t.boolean :right_column, :default => false
      t.text :content
      t.text :content_html

      t.timestamps
    end
  end
end
