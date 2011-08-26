class CreateQuestionRoleRequests < ActiveRecord::Migration
  def self.up
    create_table :question_role_requests do |t|
      t.integer :question_role_id
      t.boolean :toggle_is_author
      t.boolean :toggle_is_copyright_holder
      t.boolean :toggle_is_maintainer
      t.integer :requestor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_role_requests
  end
end
