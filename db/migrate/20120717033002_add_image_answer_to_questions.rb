class AddImageAnswerToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :image_answer, :boolean
  end
end
