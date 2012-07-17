# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# For http://apidock.com/rails/ActionDispatch/TestProcess/fixture_file_upload
include ActionDispatch::TestProcess

# Workaround to make fixture_file_upload work in Rails 3.2
def (self.class).fixture_path
  "#{::Rails.root}/test/fixtures/"
end

# Helpers
def next_email(first_name, last_name)
  first_name_s = first_name.gsub(/\W/, '')
  last_name_s = first_name.gsub(/\W/, '')
  "#{first_name_s}.#{last_name_s}#{FactoryGirl.generate :email_suffix}"
end

def unique_username(first_name, last_name)
  first_name_s = first_name.gsub(/\W/, '')
  last_name_s = first_name.gsub(/\W/, '')
  "#{first_name_s[0,3]}#{last_name_s[0,4]}" + "#{SecureRandom.hex(4)}"
end

def common_license
  if License.all.empty?
    FactoryGirl.create(:license)
  end
  
  License.first
end

def make_simple_question(options = {})
  options[:answer_credits] ||= []
  sq = options[:question_setup].nil? ? 
       FactoryGirl.create(:simple_question) :
       FactoryGirl.create(:simple_question, :question_setup => options[:question_setup])
  sq.answer_choices = 
    options[:answer_credits].map!{|c| FactoryGirl.build(:answer_choice, :credit => c)}

  sq.question_setup.content = "" if options[:no_setup] 
  
  user = FactoryGirl.create(:user)
  
  sq.create!(user) if (options[:method] == :create || options[:publish] || options[:published])

  if (options[:publish] || options[:published])
    sq.publish!(user)
  end
    
  sq
end

def make_multipart_question(options = {})
  qq = FactoryGirl.create(:multipart_question)

  sq = make_simple_question({:question_setup => qq.question_setup, :publish => true})
  qq.add_parts(sq)
  
  
  user = FactoryGirl.create(:user)
  
  qq.create!(user) if (options[:method] == :create || options[:publish] || options[:published])

  if (options[:publish] || options[:published])
    qq.publish!(user)
  end
  qq
end

def make_matching_question(options = {})
  options[:matchings] ||= []
  mq = options[:question_setup].nil? ? 
       FactoryGirl.create(:matching_question) :
       FactoryGirl.create(:matching_question, :question_setup => options[:question_setup])
  mq.matchings = 
    options[:matchings].map!{|c| FactoryGirl.build(:matching, :content => c)}

  mq.question_setup.content = "" if options[:no_setup] 
  
  user = FactoryGirl.create(:user)
  
  mq.create!(user) if (options[:method] == :create || options[:publish] || options[:published])

  if (options[:publish] || options[:published])
    mq.publish!(user)
  end
    
  mq
end

def make_project(options = {})
  options[:num_questions] ||= 0
  options[:num_members] ||= 0
  
  ww = FactoryGirl.build(:project)

  ww.project_questions = Array.new(options[:num_questions]) { |n| 
    FactoryGirl.build(:project_question, :project => ww)
  }

  ww.project_members = Array.new(options[:num_members]) { |n|
    FactoryGirl.build(:project_member, :project => ww)
  }
  
  ww.save! if (options[:method] == :create)
  ww
end

FactoryGirl.define do

  ###############################################################################
  #
  # Common sequences
  #

  sequence :content do |n|
    "#{n} #{Faker::Lorem.paragraph(2)}"
  end

  sequence :couple_of_words do |n|
    "#{n} #{Faker::Lorem.words.join(" ")}"
  end

  sequence :unique_number do |n| n end

  sequence :email_suffix do |n|
    "#{SecureRandom.hex(6)}#{n}@example.com"
  end

  sequence :password do |n|
    "G#{n}$$heb..4"
  end

  ###############################################################################
  #
  # Factories
  #

  factory :license do |f|
    f.short_name "Simple License"
    f.long_name "A Very Simple License"  
    f.url "http://www.iana.org/domains/example/"
    f.agreement_partial_name "Agreement Partial Name"
  end

  factory :simple_question do |f|
    f.content { FactoryGirl.generate(:couple_of_words) }
    f.association :question_setup
    f.number { FactoryGirl.generate(:unique_number) }
    f.license_id { common_license.id }
    f.version nil
  end
  
  factory :matching_question do |f|
    f.content { FactoryGirl.generate(:couple_of_words) }
    f.association :question_setup
    f.number { FactoryGirl.generate(:unique_number) }
    f.license_id { common_license.id }
    f.version nil
  end

  factory :question_setup do |f|
    f.content {FactoryGirl.generate :content}
  end

  factory :user do |f|
    f.first_name Faker::Name::first_name + FactoryGirl.generate(:unique_number).to_s
    f.last_name Faker::Name::last_name
    f.username {|u| unique_username(u.first_name, u.last_name)}
    f.email {|u| next_email(u.first_name, u.last_name)}
    f.is_administrator false
    f.password {FactoryGirl.generate :password}
    f.password_confirmation {|u| "#{u.password}"}
    f.confirmed_at {Time.now}
  end

  factory :user_profile do |f|
    f.association :user
    f.project_member_email true
    f.role_request_email true
  end

  factory :question_collaborator do |f|
    f.association :question, :factory => :simple_question
    f.association :user
  end

  factory :simple_question_with_choices, :parent => :simple_question do |f|
    f.after(:build) do |sq|
      sq.answer_choices = [FactoryGirl.build(:answer_choice, :credit => 1), 
                           FactoryGirl.build(:answer_choice)]
    end
  end
  
  factory :matching_question_with_matchings, :parent => :matching_question do |f|
    f.after(:build) do |sq|
      sq.matchings = [FactoryGirl.build(:matching, :question => sq), 
                      FactoryGirl.build(:matching, :question => sq)]
    end
  end

  factory :answer_choice do |f|
    f.content {FactoryGirl.generate :content}
    f.credit 0
  end
  
  factory :matching do |f|
    f.association :question, :factory => :matching_question
    f.content {FactoryGirl.generate :content}
    f.choice_id 0
    f.matched_id 0
    f.column ""
  end

  factory :multipart_question do |f|
    f.association :question_setup
    f.license_id { common_license.id }
  end

  factory :question_part do |f|
    f.association :multipart_question
    f.association :child_question, :factory => :simple_question
  end

  factory :project do |f|
    f.name {FactoryGirl.generate :couple_of_words}
  end

  factory :project_question do |f|
    f.association :project
    f.association :question, :factory => :simple_question
  end

  factory :project_member do |f|
    f.association :project
    f.association :user
    f.is_default false
  end

  factory :question_role_request do |f|
    f.association :question_collaborator, :factory => :question_collaborator
    f.toggle_is_author false
    f.toggle_is_copyright_holder false
    f.association :requestor, :factory => :user
  end

  factory :question_dependency_pair do |f|
    f.association :independent_question, :factory => :simple_question
    f.association :dependent_question, :factory => :simple_question
    f.kind "requirement"
  end

  factory :announcement do |f|
    f.association :user
    f.subject {FactoryGirl.generate :couple_of_words}
    f.body {FactoryGirl.generate :content}
    f.force false
  end

  factory :asset do |f|
    # http://apidock.com/rails/ActionDispatch/TestProcess/fixture_file_upload
    f.attachment { fixture_file_upload("files/check_icon_v1.png", "image/png") }
    f.association :uploader, :factory => :user
  end

  factory :attachable_asset do |f|
    f.association :attachable, :factory => :simple_question
    f.association :asset
    f.description "This is a dummy description."
    f.local_name  "some.name"
  end
  
  factory :question_derivation do |f|
    f.association :source_question, :factory => :simple_question
    f.association :derived_question, :factory => :simple_question
    f.association :deriver, :factory => :user
  end

  factory :solution do |f|
    f.association :question, :factory => :simple_question
    f.association :creator, :factory => :user
    f.content { FactoryGirl.generate :content }
    f.explanation { FactoryGirl.generate :content }
  end

  factory :vote do |f|
    f.association :votable, :factory => :solution
    f.association :user
    f.thumbs_up true
  end

  factory :website_configuration do |f|
    f.name "Some name"
    f.value "Some value"
    f.value_type "text"
  end

  factory :comment do |f|
    f.association :comment_thread
    f.association :creator, :factory => :user
    f.message "Some comment"
  end

  factory :comment_thread do |f|
    f.association :commentable, :factory => :simple_question
  end

  factory :comment_thread_subscription do |f|
    f.association :comment_thread
    f.association :user
  end

  factory :message do |f|
    f.subject {FactoryGirl.generate :content}
  end

  factory :deputization do |f|
    f.association :deputizer, :factory => :user
    f.association :deputy, :factory => :user
  end

  factory :logic do |f|
    f.code "x = 2;"
    f.variables "x"
  end

end
