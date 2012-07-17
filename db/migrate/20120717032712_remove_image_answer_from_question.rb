class RemoveImageAnswerFromQuestion < ActiveRecord::Migration
  def up
    remove_column :questions, :image_answer
  end

  def down
    add_column :questions, :image_answer, :string
  end
end
