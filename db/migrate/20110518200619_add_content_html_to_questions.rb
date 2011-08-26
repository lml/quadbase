class AddContentHtmlToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :content_html, :string
  end

  def self.down
    remove_column :questions, :content_html
  end
end
