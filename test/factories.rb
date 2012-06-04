# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# For http://apidock.com/rails/ActionDispatch/TestProcess/fixture_file_upload
include ActionDispatch::TestProcess

###############################################################################
#
# Common sequences and helpers
#

Factory.sequence :content do |n|
  "#{n} #{Faker::Lorem.paragraph(2)}"
end

Factory.sequence :couple_of_words do |n|
  "#{n} #{Faker::Lorem.words.join(" ")}"
end

Factory.sequence :unique_number do |n| n end

Factory.sequence :email_suffix do |n|
  "#{SecureRandom.hex(6)}#{n}@example.com"
end

def next_email(first_name, last_name)
  first_name_s = first_name.gsub(/\W/, '')
  last_name_s = first_name.gsub(/\W/, '')
  "#{first_name_s}.#{last_name_s}#{Factory.next :email_suffix}"
end

def unique_username(first_name, last_name)
  first_name_s = first_name.gsub(/\W/, '')
  last_name_s = first_name.gsub(/\W/, '')
  "#{first_name_s[0,3]}#{last_name_s[0,4]}" + "#{SecureRandom.hex(4)}"
end

Factory.sequence :password do |n|
  "G#{n}$$heb..4"
end

def common_license
  if License.all.empty?
    Factory.create(:license)
  end
  
  License.first
end

###############################################################################
#
# Factories
#


Factory.define :license do |f|
  f.short_name "Simple License"
  f.long_name "A Very Simple License"  
  f.url "http://www.iana.org/domains/example/"
  f.agreement_partial_name "Agreement Partial Name"
end

Factory.define :simple_question do |f|
  f.content { Factory.next(:couple_of_words) }
  f.association :question_setup
  f.number { Factory.next(:unique_number) }
  f.license_id { common_license.id }
  f.version nil
end

Factory.define :question_setup do |f|
  f.content {Factory.next :content}
end

Factory.define :user do |f|
  f.first_name Faker::Name::first_name + Factory.next(:unique_number).to_s
  f.last_name Faker::Name::last_name
  f.username {|u| unique_username(u.first_name, u.last_name)}
  f.email {|u| next_email(u.first_name, u.last_name)}
  f.is_administrator false
  f.password {Factory.next :password}
  f.password_confirmation {|u| "#{u.password}"}
  f.confirmed_at {Time.now}
end

Factory.define :user_profile do |f|
  f.association :user
  f.project_member_email true
  f.role_request_email true
end

Factory.define :question_collaborator do |f|
  f.association :question, :factory => :simple_question
  f.association :user
end

Factory.define(:simple_question_with_choices, :parent => :simple_question) do |f|
  f.after_build do |sq|
    # sq.answer_choices = [Factory.build(:answer_choice, :simple_question => sq, :credit => 1), 
    #                      Factory.build(:answer_choice, :simple_question => sq)]
    sq.answer_choices = [Factory.build(:answer_choice, :credit => 1), 
                         Factory.build(:answer_choice)]
  end
end

def make_simple_question(options = {})
  options[:answer_credits] ||= []
  sq = options[:question_setup].nil? ? 
       Factory.create(:simple_question) :
       Factory.create(:simple_question, :question_setup => options[:question_setup])
  sq.answer_choices = 
    options[:answer_credits].map!{|c| Factory.build(:answer_choice, :credit => c)}

  sq.question_setup.content = "" if options[:no_setup] 
  
  user = Factory.create(:user)
  
  sq.create!(user) if (options[:method] == :create || options[:publish] || options[:published])

  if (options[:publish] || options[:published])
    sq.publish!(user)
  end
    
  sq
end

Factory.define :answer_choice do |f|
  f.content {Factory.next :content}
  f.credit 0
end

Factory.define :multipart_question do |f|
  f.association :question_setup
  f.license_id { common_license.id }
end

def make_multipart_question(options = {})
  qq = Factory.create(:multipart_question)

  sq = make_simple_question({:question_setup => qq.question_setup, :publish => true})
  qq.add_parts(sq)
  
  
  user = Factory.create(:user)
  
  qq.create!(user) if (options[:method] == :create || options[:publish] || options[:published])

  if (options[:publish] || options[:published])
    qq.publish!(user)
  end
  qq
end

Factory.define :question_part do |f|
  f.association :multipart_question
  f.association :child_question, :factory => :simple_question
end

Factory.define :project do |f|
  f.name {Factory.next :couple_of_words}
end

def make_project(options = {})
  options[:num_questions] ||= 0
  options[:num_members] ||= 0
  
  ww = Factory.build(:project)

  ww.project_questions = Array.new(options[:num_questions]) { |n| 
    Factory.build(:project_question, :project => ww)
  }

  ww.project_members = Array.new(options[:num_members]) { |n|
    Factory.build(:project_member, :project => ww)
  }
  
  ww.save! if (options[:method] == :create)
  ww
end

Factory.define :project_question do |f|
  f.association :project
  f.association :question, :factory => :simple_question
end

Factory.define :project_member do |f|
  f.association :project
  f.association :user
  f.is_default false
end

Factory.define :question_role_request do |f|
  f.association :question_collaborator, :factory => :question_collaborator
  f.toggle_is_author false
  f.toggle_is_copyright_holder false
  f.association :requestor, :factory => :user
end

Factory.define :question_dependency_pair do |f|
  f.association :independent_question, :factory => :simple_question
  f.association :dependent_question, :factory => :simple_question
  f.kind "requirement"
end

Factory.define :announcement do |f|
  f.association :user
  f.subject {Factory.next :couple_of_words}
  f.body {Factory.next :content}
  f.force false
end

Factory.define :asset do |f|
  # http://apidock.com/rails/ActionDispatch/TestProcess/fixture_file_upload
  f.attachment { fixture_file_upload("files/check_icon_v1.png", "image/png") }
  f.association :uploader, :factory => :user
end

Factory.define :attachable_asset do |f|
  f.association :attachable, :factory => :simple_question
  f.association :asset
  f.description "This is a dummy description."
  f.local_name  "some.name"
end
  
Factory.define :question_derivation do |f|
  f.association :source_question, :factory => :simple_question
  f.association :derived_question, :factory => :simple_question
  f.association :deriver, :factory => :user
end

Factory.define :solution do |f|
  f.association :question, :factory => :simple_question
  f.association :creator, :factory => :user
  f.content { Factory.next :content }
  f.explanation { Factory.next :content }
end

Factory.define :vote do |f|
  f.association :votable, :factory => :solution
  f.association :user
  f.thumbs_up true
end

Factory.define :website_configuration do |f|
  f.name "Some name"
  f.value "Some value"
  f.value_type "text"
end

Factory.define :comment do |f|
  f.association :comment_thread
  f.association :creator, :factory => :user
  f.message "Some comment"
end

Factory.define :comment_thread do |f|
  f.association :commentable, :factory => :simple_question
end

Factory.define :comment_thread_subscription do |f|
  f.association :comment_thread
  f.association :user
end

Factory.define :message do |f|
  f.subject {Factory.next :content}
end

Factory.define :deputization do |f|
  f.association :deputizer, :factory => :user
  f.association :deputy, :factory => :user
end

Factory.define :logic do |f|
  f.code "x = 2;"
  f.variables "x"
end
