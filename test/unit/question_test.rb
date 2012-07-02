# encoding: UTF-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign number, version, question_type, license_id, content_html, locked_by, locked_at" do
    number = 20
    version = 11
    question_type = "MultipartQuestion"
    license_id = 10
    content_html = "Some content"
    locked_by = 15
    locked_at = Time.now
    sq = SimpleQuestion.new(:number => number,
                            :version => version,
                            :question_type => question_type,
                            :license_id => license_id,
                            :content_html => content_html,
                            :locked_by => locked_by,
                            :locked_at => locked_at)
    assert sq.number != number
    assert sq.version != version
    assert sq.question_type != question_type
    assert sq.license_id != license_id
    assert sq.content_html != content_html
    assert sq.locked_by != locked_by
    assert sq.locked_at != locked_at
  end

  test "published question ID" do
    sq = make_simple_question({:answer_credits => [0,1,0,0], 
                               :published => true,
                               :method => :create})

    assert_equal "q#{sq.number}v1", sq.to_param
  end
  
  test "draft question ID" do
    q = make_simple_question
    assert_equal "d#{q.id}", q.to_param
  end
  
  test "publish" do
    q = make_simple_question(:method => :create, :set_license => true)
    u = FactoryGirl.create(:user)
    q.set_initial_question_roles(u)
    
    assert_nothing_raised(ActiveRecord::RecordInvalid) {q.publish!(u)}
    assert_equal 1, q.version
    assert q.is_published?
  end
  
  # test "can't publish because superseded" do
  #   # q_pub = make_simple_question(:method => :create, :set_license => true, :published => :true)
  #   
  #   flunk "Not yet implemented"
  # end
  
  test "can't publish because already published" do 
    q_pub = make_simple_question(:method => :create, :set_license => true, :published => :true)
    q_pub.publish!(FactoryGirl.create(:user))
    assert !q_pub.errors.empty?
  end
  
  test "can't publish because missing roles" do 
    q = make_simple_question()
    u = FactoryGirl.create(:user)
    q.publish!(u)
    assert !q.errors.empty?
  end
  
  # test "publishing assigns incrementing number" do 
  #   flunk "Not yet implemented"
  # end

  test "can't destroy published questions" do 
    q = make_simple_question(:method => :create, :published => true)
    q.destroy
    
    assert !q.errors.empty?
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Question.find(q.id) }
  end

  # test "find by number and version" do 
  #   flunk "Not yet implemented"
  # end
  
  test "has_all_roles" do
    q = make_simple_question
    u = FactoryGirl.create(:user)
    
    c = FactoryGirl.create(:question_collaborator, {:question => q, 
                                                :user => u, 
                                                :is_author => true,
                                                :is_copyright_holder => true})
                                        
    assert q.has_all_roles?
    
    c.is_author = false
    c.save!
    q.reload
    
    assert !q.has_all_roles?
    
    c.is_author = true
    c.is_copyright_holder = false
    c.save!
    q.reload
    
    assert !q.has_all_roles?
  end
  
  test "superseded" do 
    q1 = make_simple_question(:method => :build)
    u = FactoryGirl.create(:user)
    q1.create!(u)
    q1.publish!(u)

    assert q1.is_published?
    
    q2 = q1.new_version!(u)
    q3 = q1.new_version!(u)

    assert !q2.superseded?
    
    sleep 1 #second
    q3.publish!(u)

    assert q3.is_published?

    assert q2.superseded?
  end
  
  # test "is_latest?" do 
  #   flunk "Not yet implemented"
  # end
  
  test "next available version" do 
    q = make_simple_question(:method => :create, :published => true)
    assert_equal 2, q.next_available_version
  end
  
  test "delete destroys appropriate assocs" do
    q = make_simple_question()
    pq = FactoryGirl.create(:project_question, :question => q)
    c = FactoryGirl.create(:question_collaborator, :question => q)

    assert q.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Question.find(q.id) }

    assert_raise(ActiveRecord::RecordNotFound) { QuestionCollaborator.find(c.id) }
    assert_raise(ActiveRecord::RecordNotFound) { ProjectQuestion.find(pq.id) }
  end
  
  test "create" do
    q = make_simple_question()
    u = FactoryGirl.create(:user)
    
    q.create!(u)
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Question.find(q.id) }
    q = Question.find(q.id)
    assert q.has_role?(u, :author)
    assert q.has_role?(u, :copyright_holder)
    assert Project.default_for_user!(u).questions(true).include?(q)
  end
  
  test "new_derivation!" do
    q = make_simple_question(:set_license => true)
    u = FactoryGirl.create(:user)
    q.create!(u)
    q.publish!(u)
    
    q_derived = q.new_derivation!(u)
    
    assert_equal q_derived.source_question.id, q.id
    assert_not_equal q_derived.id, q.id
    assert_nil q_derived.version
    assert q_derived.has_role?(u, :author)
    assert q_derived.has_role?(u, :copyright_holder)
    
    assert_equal q_derived.content, q.content
    assert_equal q_derived.license_id, q.license_id
    
    #TODO test derived_questions and source_question
  end

  test "copy_with_derivation" do
    q = make_simple_question(:set_license => true)
    u = FactoryGirl.create(:user)
    q.create!(u)
    q.publish!(u)
    
    q_derived = q.new_derivation!(u)

    qc = q_derived.content_copy
    qc.create!(u, :source_question => q_derived.source_question, :deriver_id => u.id)

    assert_equal qc.source_question, q
    assert_equal qc.question_source.deriver, u
  end
  
  test "new_version!" do
    q = make_simple_question(:set_license => true)
    u = FactoryGirl.create(:user)
    q.create!(u)
    q.publish!(u)
    
    q_newver = q.new_version!(u)
    
    assert_equal q_newver.number, q.number
    assert_nil q_newver.version
    assert q_newver.has_role?(u, :author)
    assert q_newver.has_role?(u, :copyright_holder)
    
    q_newver.publish!(u)
    
    assert_equal q.version+1, q_newver.version
    
    #TODO test prior_version
  end

  test 'id search' do
    user = FactoryGirl.create(:user)

    sq0 = FactoryGirl.create(:simple_question, :content => 'This is in your project')

    sq1 = make_simple_question(:set_license => true)
    sq1.content = 'This is published (old version)'
    sq1.create!(user)
    sq1.publish!(user)
    
    sq2 = sq1.new_version!(user)
    sq2.content = 'This is published (new version)'
    sq2.publish!(user)
    
    FactoryGirl.create(:project_question, :question => sq0,
                   :project => Project.default_for_user!(user))

    search0 = Question.search('All Questions', 'All Places', 'ID/Number', '', user)
    search1 = Question.search('All Questions', 'All Places', 'ID/Number', "#{sq2.id}", user)
    search2 = Question.search('All Questions', 'All Places', 'ID/Number', " #{sq2.id} ", user)
    search3 = Question.search('All Questions', 'All Places', 'ID/Number', "d#{sq0.id}", user)
    search4 = Question.search('All Questions', 'All Places', 'ID/Number', " d. #{sq0.id} ", user)
    search5 = Question.search('All Questions', 'All Places', 'ID/Number', "q#{sq1.number}", user)
    search6 = Question.search('All Questions', 'All Places', 'ID/Number', " q. #{sq1.number} ", user)
    search7 = Question.search('All Questions', 'All Places', 'ID/Number', "q#{sq1.number}v#{sq1.version}", user)
    search8 = Question.search('All Questions', 'All Places', 'ID/Number', " q. #{sq1.number}, v. #{sq1.version} ", user)
    search9 = Question.search('All Questions', 'All Places', 'ID/Number', "q#{sq1.number}v", user)

    assert search0.include?(sq0)
    assert !search0.include?(sq1)
    assert search0.include?(sq2)

    assert !search1.include?(sq0)
    assert !search1.include?(sq1)
    assert search1.include?(sq2)

    assert !search2.include?(sq0)
    assert !search2.include?(sq1)
    assert search2.include?(sq2)

    assert search3.include?(sq0)
    assert !search3.include?(sq1)
    assert !search3.include?(sq2)

    assert search4.include?(sq0)
    assert !search4.include?(sq1)
    assert !search4.include?(sq2)

    assert !search5.include?(sq0)
    assert !search5.include?(sq1)
    assert search5.include?(sq2)

    assert !search6.include?(sq0)
    assert !search6.include?(sq1)
    assert search6.include?(sq2)

    assert !search7.include?(sq0)
    assert search7.include?(sq1)
    assert !search7.include?(sq2)

    assert !search8.include?(sq0)
    assert search8.include?(sq1)
    assert !search8.include?(sq2)

    assert !search9.include?(sq0)
    assert !search9.include?(sq1)
    assert !search9.include?(sq2)
  end

  test 'content search' do
    sq0 = FactoryGirl.create(:simple_question, :content => '')
    sq1 = FactoryGirl.create(:simple_question, :content => 'This is in your project')
    sq2 = FactoryGirl.create(:simple_question, :content => 'This is NOT in your project')
    sq3 = FactoryGirl.create(:simple_question, :content => 'This is published', :version => '1.0')
    sq4 = FactoryGirl.create(:simple_question, :content => 'This is published and in your project', :version => '1.0')

    user = FactoryGirl.create(:user)
    FactoryGirl.create(:project_question, :question => sq0,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq1,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq4,
                   :project => Project.default_for_user!(user))

    search0 = Question.search('All Questions', 'All Places', 'Content', '', user)
    search1 = Question.search('All Questions', 'Published Questions', 'Content', '', user)
    search2 = Question.search('All Questions', 'My Drafts', 'Content', '', user)
    search3 = Question.search('All Questions', 'My Projects', 'Content', '', user)
    search4 = Question.search('All Questions', 'All Places', 'Content', 'not', user)
    search5 = Question.search('All Questions', 'My Projects', 'Content', 'this', user)

    assert search0.include?(sq0)
    assert search0.include?(sq1)
    assert !search0.include?(sq2)
    assert search0.include?(sq3)
    assert search0.include?(sq4)

    assert !search1.include?(sq0)
    assert !search1.include?(sq1)
    assert !search1.include?(sq2)
    assert search1.include?(sq3)
    assert search1.include?(sq4)

    assert search2.include?(sq0)
    assert search2.include?(sq1)
    assert !search2.include?(sq2)
    assert !search2.include?(sq3)
    assert !search2.include?(sq4)

    assert search3.include?(sq0)
    assert search3.include?(sq1)
    assert !search3.include?(sq2)
    assert !search3.include?(sq3)
    assert search3.include?(sq4)

    assert !search4.include?(sq0)
    assert !search4.include?(sq1)
    assert !search4.include?(sq2)
    assert !search4.include?(sq3)
    assert !search4.include?(sq4)

    assert !search5.include?(sq0)
    assert search5.include?(sq1)
    assert !search5.include?(sq2)
    assert !search5.include?(sq3)
    assert search5.include?(sq4)
  end

  test 'simple question content search' do
    sq0 = FactoryGirl.create(:simple_question, :content => '')
    sq1 = FactoryGirl.create(:simple_question, :content => 'This is in your project')
    sq2 = FactoryGirl.create(:simple_question, :content => 'This is NOT in your project')
    sq3 = FactoryGirl.create(:simple_question, :content => 'This is published', :version => '1.0')
    sq4 = FactoryGirl.create(:simple_question, :content => 'This is published and in your project', :version => '1.0')

    user = FactoryGirl.create(:user)
    FactoryGirl.create(:project_question, :question => sq0,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq1,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq4,
                   :project => Project.default_for_user!(user))

    search0 = Question.search('Simple Questions', 'All Places', 'Content', '', user)
    search1 = Question.search('Simple Questions', 'Published Questions', 'Content', '', user)
    search2 = Question.search('Simple Questions', 'My Drafts', 'Content', '', user)
    search3 = Question.search('Simple Questions', 'My Projects', 'Content', '', user)
    search4 = Question.search('Simple Questions', 'All Places', 'Content', 'not', user)
    search5 = Question.search('Simple Questions', 'My Projects', 'Content', 'this', user)

    assert search0.include?(sq0)
    assert search0.include?(sq1)
    assert !search0.include?(sq2)
    assert search0.include?(sq3)
    assert search0.include?(sq4)

    assert !search1.include?(sq0)
    assert !search1.include?(sq1)
    assert !search1.include?(sq2)
    assert search1.include?(sq3)
    assert search1.include?(sq4)

    assert search2.include?(sq0)
    assert search2.include?(sq1)
    assert !search2.include?(sq2)
    assert !search2.include?(sq3)
    assert !search2.include?(sq4)

    assert search3.include?(sq0)
    assert search3.include?(sq1)
    assert !search3.include?(sq2)
    assert !search3.include?(sq3)
    assert search3.include?(sq4)

    assert !search4.include?(sq0)
    assert !search4.include?(sq1)
    assert !search4.include?(sq2)
    assert !search4.include?(sq3)
    assert !search4.include?(sq4)

    assert !search5.include?(sq0)
    assert search5.include?(sq1)
    assert !search5.include?(sq2)
    assert !search5.include?(sq3)
    assert search5.include?(sq4)
  end

  test 'tag search' do
    sq0 = FactoryGirl.create(:simple_question, :content => '')
    sq1 = FactoryGirl.create(:simple_question, :content => 'This is in your project')
    sq2 = FactoryGirl.create(:simple_question, :content => 'This is also in your project')
    sq3 = FactoryGirl.create(:simple_question, :content => 'This is published and in your project', :version => '1.0')
    sq4 = FactoryGirl.create(:simple_question, :content => 'This is also published and in your project', :version => '1.0')

    user = FactoryGirl.create(:user)
    FactoryGirl.create(:project_question, :question => sq0,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq1,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq2,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq3,
                   :project => Project.default_for_user!(user))
    FactoryGirl.create(:project_question, :question => sq4,
                   :project => Project.default_for_user!(user))

    tags = sq0.tag_list.concat(["Some Tag", "Another Tag"]).join(", ")
    sq0.update_attribute(:tag_list, tags)

    tags = sq1.tag_list.concat(["Some Tag"]).join(", ")
    sq1.update_attribute(:tag_list, tags)

    tags = sq2.tag_list.concat(["Another Tag"]).join(", ")
    sq2.update_attribute(:tag_list, tags)

    tags = sq3.tag_list.concat(["Some Tag"]).join(", ")
    sq3.update_attribute(:tag_list, tags)

    tags = sq4.tag_list.concat(["Another Tag"]).join(", ")
    sq4.update_attribute(:tag_list, tags)


    search0 = Question.search('Simple Questions', 'All Places', 'Tags', '%Tag', user)
    search1 = Question.search('Simple Questions', 'Published Questions', 'Tags', 'Some Tag', user)
    search2 = Question.search('Simple Questions', 'Published Questions', 'Tags', 'Another Tag', user)
    search3 = Question.search('Simple Questions', 'My Drafts', 'Tags', 'Some Tag', user)
    search4 = Question.search('Simple Questions', 'My Drafts', 'Tags', 'Another Tag', user)
    search5 = Question.search('Simple Questions', 'My Projects', 'Tags', 'Some Tag', user)
    search6 = Question.search('Simple Questions', 'My Projects', 'Tags', 'Another Tag', user)

    assert search0.include?(sq0)
    assert search0.include?(sq1)
    assert search0.include?(sq2)
    assert search0.include?(sq3)
    assert search0.include?(sq4)

    assert !search1.include?(sq0)
    assert !search1.include?(sq1)
    assert !search1.include?(sq2)
    assert search1.include?(sq3)
    assert !search1.include?(sq4)

    assert !search2.include?(sq0)
    assert !search2.include?(sq1)
    assert !search2.include?(sq2)
    assert !search2.include?(sq3)
    assert search2.include?(sq4)

    assert search3.include?(sq0)
    assert search3.include?(sq1)
    assert !search3.include?(sq2)
    assert !search3.include?(sq3)
    assert !search3.include?(sq4)

    assert search4.include?(sq0)
    assert !search4.include?(sq1)
    assert search4.include?(sq2)
    assert !search4.include?(sq3)
    assert !search4.include?(sq4)

    assert search5.include?(sq0)
    assert search5.include?(sq1)
    assert !search5.include?(sq2)
    assert search5.include?(sq3)
    assert !search5.include?(sq4)

    assert search6.include?(sq0)
    assert !search6.include?(sq1)
    assert search6.include?(sq2)
    assert !search6.include?(sq3)
    assert search6.include?(sq4)
  end
  
  test "dependency_pair" do
    prereq = make_simple_question(:publish => true, :method => :create)
    dependent = make_simple_question(:publish => false, :method => :create)
    
    supporting = make_simple_question(:publish => true, :method => :create)
    supported = make_simple_question(:publish => false, :method => :create)
    
    qdpr = FactoryGirl.create(:question_dependency_pair, 
                          :independent_question => prereq, 
                          :dependent_question => dependent, 
                          :kind => "requirement")
    
    qdps = FactoryGirl.create(:question_dependency_pair, 
                          :independent_question => supporting, 
                          :dependent_question => supported, 
                          :kind => "support")
    
    assert_equal prereq.dependent_question_pairs.count, 1
    assert prereq.dependent_question_pairs.first.is_requirement?
    assert_equal prereq.dependent_questions.first, dependent
    assert_equal dependent.prerequisite_questions.first, prereq
    
    assert_equal supporting.supported_question_pairs.count, 1
    assert supporting.supported_question_pairs.first.is_support?
    assert_equal supporting.supported_questions.first, supported
    assert_equal supported.supporting_questions.first, supporting
  end

  test 'get_lock' do
    q = FactoryGirl.create(:simple_question)
    u = FactoryGirl.create(:user)
    u2 = FactoryGirl.create(:user)
    assert !q.is_locked?
    assert !q.has_lock?(u)
    assert !q.has_lock?(u2)
    assert q.get_lock!(u)
    assert q.is_locked?
    assert q.has_lock?(u)
    assert !q.has_lock?(u2)
    assert !q.get_lock!(u2)
    assert q.is_locked?
    assert q.has_lock?(u)
    assert !q.has_lock?(u2)
  end

  test 'check_and_unlock' do
    q = FactoryGirl.create(:simple_question)
    u = FactoryGirl.create(:user)
    u2 = FactoryGirl.create(:user)
    assert !q.is_locked?
    assert !q.has_lock?(u)
    assert !q.has_lock?(u2)
    assert !q.check_and_unlock!(u)
    assert !q.check_and_unlock!(u2)
    assert q.get_lock!(u)
    assert q.is_locked?
    assert q.has_lock?(u)
    assert q.check_and_unlock!(u)
    assert !q.is_locked?
    assert !q.has_lock?(u)
  end
  
  test "has_role_permission_as_deputy" do
    qc = FactoryGirl.create(:question_collaborator, :is_author => true)
    dep_user = FactoryGirl.create(:user)
    FactoryGirl.create(:deputization, :deputizer => qc.user, :deputy => dep_user)
    
    assert !qc.user.deputies.empty?
    assert !dep_user.deputizers.empty?
    
    assert qc.question.has_role_permission_as_deputy?(dep_user, :any)
    assert qc.question.has_role_permission?(dep_user, :any)
  end
  
  test "blank setups removed on publish" do
    sq = make_simple_question(:method => :create, :no_setup => true)
    u = FactoryGirl.create(:user)
    
    assert !sq.question_setup.nil?
    qs_id = sq.question_setup.id
    
    sq.publish!(u)
    sq.reload
    
    assert sq.question_setup.nil?
    assert_raise(ActiveRecord::RecordNotFound) {QuestionSetup.find(qs_id)}
  end
  
  test "funny characters" do
    q = make_simple_question(:method => :create)
    assert_nothing_raised{q.update_attributes({:content => "\n â".encode("UTF-8")})}
  end
  
  # test "derive with errored question doesn't create QuestionDerivation" do
  #   flunk "Not yet implemented"
  # end
  
  # TODO implement the following tests
  # 
  # test "project_member can publish" do
  # end
  #
  # test "is_derivation?" do
  # end
  # 
  # test "has_earlier_versions?" do
  # end
  # 
  # test "get_ancestor_question" do
  # end
  # 
  # test "assign_number" do
  # end
  
  
end
