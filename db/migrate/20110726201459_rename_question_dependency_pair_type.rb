class RenameQuestionDependencyPairType < ActiveRecord::Migration
  def self.up
    rename_column :question_dependency_pairs, :type, :kind
  end

  def self.down
    rename_column :question_dependency_pairs, :kind, :type
  end
end
