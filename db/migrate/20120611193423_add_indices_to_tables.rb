class AddIndicesToTables < ActiveRecord::Migration
  def change
    add_index :announcements, :user_id
    add_index :answer_choices, :question_id
    add_index :assets, :uploader_id
    add_index :attachable_assets, [:attachable_id, :attachable_type, :local_name], :unique => true, :name => "index_aa_on_a_id_and_a_type_and_local_name"
    add_index :comment_thread_subscriptions, [:comment_thread_id, :user_id], :unique => true, :name => "index_cts_on_ct_id_and_u_id"
    add_index :comment_threads, [:commentable_id, :commentable_type]
    add_index :comments, :comment_thread_id
    add_index :comments, :creator_id
    add_index :deputizations, [:deputizer_id, :deputy_id], :unique => true
    add_index :deputizations, :deputy_id
    add_index :licenses, :is_default
    add_index :logic_libraries, :number, :unique => true
    add_index :logic_libraries, :always_required
    add_index :logic_library_versions, :logic_library_id
    add_index :logic_library_versions, :version
    add_index :logic_library_versions, :deprecated
    add_index :logics, [:logicable_id, :logicable_type], :unique => true
    add_index :logics, :required_logic_library_version_ids
    add_index :project_members, [:project_id, :user_id], :unique => true
    add_index :project_members, [:user_id, :is_default]
    add_index :project_questions, [:project_id, :question_id], :unique => true
    add_index :project_questions, :question_id
    add_index :question_collaborators, [:question_id, :position], :unique => true
    add_index :question_collaborators, [:user_id, :question_id], :unique => true
    add_index :question_collaborators, :is_author
    add_index :question_collaborators, :is_copyright_holder
    add_index :question_dependency_pairs, [:independent_question_id, :dependent_question_id, :kind], :unique => true, :name => "index_qdp_on_iq_id_and_dq_id_and_kind"
    add_index :question_dependency_pairs, :dependent_question_id
    add_index :question_derivations, :source_question_id
    add_index :question_derivations, :derived_question_id, :unique => true
    add_index :question_parts, [:multipart_question_id, :order], :unique => true
    add_index :question_parts, [:child_question_id, :multipart_question_id], :unique => true, :name => "index_qp_on_cq_id_and_mq_id"
    add_index :question_role_requests, [:question_collaborator_id, :toggle_is_author, :toggle_is_copyright_holder], :unique => true, :name => "index_qrr_on_qc_id_and_t_i_a_and_t_i_ch"
    add_index :questions, [:number, :version]
    add_index :questions, :version
    add_index :questions, :question_type
    add_index :questions, :question_setup_id
    add_index :questions, :license_id
    add_index :questions, :updated_at
    add_index :solutions, [:creator_id, :is_visible]
    add_index :solutions, :question_id
    add_index :user_profiles, :user_id
    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :is_administrator
    add_index :users, :username, :unique => true
    add_index :users, :disabled_at
    add_index :votes, [:votable_id, :votable_type, :user_id], :unique => true
    add_index :votes, :thumbs_up
    add_index :website_configurations, :name, :unique => true
  end
end
