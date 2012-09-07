class AddAnswerCanBeSketchedToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :answer_can_be_sketched, :boolean
  end
end
