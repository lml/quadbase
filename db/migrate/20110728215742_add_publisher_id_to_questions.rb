class AddPublisherIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :publisher_id, :integer
  end

  def self.down
    remove_column :questions, :publisher_id
  end
end
