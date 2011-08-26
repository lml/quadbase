class AddContentHtmlToAnswerChoices < ActiveRecord::Migration
  def self.up
    add_column :answer_choices, :content_html, :string
  end

  def self.down
    remove_column :answer_choices, :content_html
  end
end
