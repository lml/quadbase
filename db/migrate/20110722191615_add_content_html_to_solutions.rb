class AddContentHtmlToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :content_html, :text
  end

  def self.down
    remove_column :solutions, :content_html
  end
end
