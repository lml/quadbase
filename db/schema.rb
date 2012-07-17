# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120424015014) do

  create_table "announcements", :force => true do |t|
    t.integer  "user_id"
    t.text     "subject"
    t.text     "body"
    t.boolean  "force"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "answer_choices", :force => true do |t|
    t.integer  "question_id"
    t.text     "content"
    t.decimal  "credit"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "content_html", :limit => 255
  end

  create_table "assets", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "uploader_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "attachable_assets", :force => true do |t|
    t.integer  "attachable_id"
    t.integer  "asset_id"
    t.string   "local_name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "description"
    t.string   "attachable_type"
  end

  create_table "comment_thread_subscriptions", :force => true do |t|
    t.integer  "comment_thread_id"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "unread_count",      :default => 0
  end

  create_table "comment_threads", :force => true do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "comment_thread_id"
    t.text     "message"
    t.integer  "creator_id"
    t.boolean  "is_log"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "deputizations", :force => true do |t|
    t.integer  "deputizer_id"
    t.integer  "deputy_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "licenses", :force => true do |t|
    t.string   "short_name"
    t.string   "long_name"
    t.string   "url"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "agreement_partial_name"
    t.boolean  "is_default"
  end

  create_table "logic_libraries", :force => true do |t|
    t.string   "name"
    t.integer  "number"
    t.text     "summary"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.boolean  "always_required"
  end

  create_table "logic_library_versions", :force => true do |t|
    t.integer  "logic_library_id"
    t.integer  "version"
    t.text     "code"
    t.text     "minified_code"
    t.boolean  "deprecated"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "logics", :force => true do |t|
    t.text     "code"
    t.string   "variables"
    t.string   "logicable_type"
    t.integer  "logicable_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.text     "cached_code"
    t.string   "variables_array"
    t.string   "required_logic_library_version_ids"
  end

  create_table "matchings", :force => true do |t|
    t.integer  "question_id"
    t.integer  "choice_id"
    t.integer  "matched_id"
    t.string   "content"
    t.string   "column"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "project_members", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.boolean  "is_default"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "project_questions", :force => true do |t|
    t.integer  "project_id"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "question_collaborators", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.integer  "position"
    t.boolean  "is_author",                    :default => false
    t.boolean  "is_copyright_holder",          :default => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "question_role_requests_count", :default => 0
  end

  create_table "question_dependency_pairs", :force => true do |t|
    t.integer  "independent_question_id"
    t.integer  "dependent_question_id"
    t.string   "kind"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "question_derivations", :force => true do |t|
    t.integer  "derived_question_id"
    t.integer  "source_question_id"
    t.integer  "deriver_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "question_parts", :force => true do |t|
    t.integer  "multipart_question_id"
    t.integer  "child_question_id"
    t.integer  "order"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "question_role_requests", :force => true do |t|
    t.integer  "question_collaborator_id"
    t.boolean  "toggle_is_author"
    t.boolean  "toggle_is_copyright_holder"
    t.integer  "requestor_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "is_approved",                :default => false
    t.boolean  "is_accepted",                :default => false
  end

  create_table "question_setups", :force => true do |t|
    t.text     "content"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "content_html", :limit => 255
  end

  create_table "questions", :force => true do |t|
    t.integer  "number"
    t.integer  "version"
    t.string   "question_type"
    t.text     "content"
    t.integer  "question_setup_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "license_id"
    t.text     "content_html",      :limit => 255
    t.integer  "locked_by",                        :default => -1
    t.datetime "locked_at"
    t.integer  "publisher_id"
    t.boolean  "changes_solution",                 :default => false
    t.text     "code"
    t.string   "variables"
  end

  create_table "solutions", :force => true do |t|
    t.integer  "creator_id"
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "content_html"
    t.text     "explanation"
    t.boolean  "is_visible"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "project_member_email",  :default => true
    t.boolean  "role_request_email",    :default => true
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "announcement_email"
    t.boolean  "auto_author_subscribe", :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_administrator",       :default => false
    t.string   "username"
    t.datetime "disabled_at"
    t.integer  "unread_message_count",   :default => 0
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "thumbs_up"
    t.string   "votable_type"
    t.integer  "votable_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "website_configurations", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.string   "value_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
