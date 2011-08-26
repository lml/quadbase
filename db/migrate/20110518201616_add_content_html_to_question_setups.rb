class AddContentHtmlToQuestionSetups < ActiveRecord::Migration
  def self.up
    add_column :question_setups, :content_html, :string
  end

  def self.down
    remove_column :question_setups, :content_html
  end
end
