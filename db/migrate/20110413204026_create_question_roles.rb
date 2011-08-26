class CreateQuestionRoles < ActiveRecord::Migration
  def self.up
    create_table :question_roles do |t|
      t.integer :user_id
      t.integer :quid_id
      t.integer :position
      t.boolean :is_author
      t.boolean :is_maintainer
      t.boolean :is_copyright_holder

      t.timestamps
    end
  end

  def self.down
    drop_table :question_roles
  end
end
