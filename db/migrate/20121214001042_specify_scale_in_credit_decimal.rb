class SpecifyScaleInCreditDecimal < ActiveRecord::Migration
  def up
    change_column :answer_choices, :credit, :decimal, :precision => 16, :scale => 15
  end

  def down
  end
end
