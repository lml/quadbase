class ChangeDataTypeForContentHtml < ActiveRecord::Migration
  def self.up
    change_table :questions do |t|
      t.change :content_html, :text
    end
    change_table :question_setups do |t|
      t.change :content_html, :text
    end
    change_table :answer_choices do |t|
      t.change :content_html, :text
    end
  end

  def self.down
    change_table :questions do |t|
      t.change :content_html, :string
    end
    change_table :question_setups do |t|
      t.change :content_html, :string
    end
    change_table :answer_choices do |t|
      t.change :content_html, :string
    end
  end
end
