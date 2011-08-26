class ChangeDefaultsOnQuestionRoles < ActiveRecord::Migration
  def self.up
    change_column_default :question_roles, :is_author, false
    change_column_default :question_roles, :is_maintainer, false
    change_column_default :question_roles, :is_copyright_holder, false
  end

  def self.down
  end
end
