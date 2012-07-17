# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class MatchingQuestionTest < ActiveSupport::TestCase

  test "create" do
    mq = FactoryGirl.create(:matching_question)
    assert_not_nil mq
  end

  test "matchings" do
    m = FactoryGirl.create(:matching)
    assert !m.question.matchings.empty?, 'a'
    
    mq = FactoryGirl.create(:matching_question)

    mq.matchings << m
    assert m.errors.empty?
    assert !mq.matchings.empty?
  end

  test "add_matchings" do
    mq = FactoryGirl.create(:matching_question)
    
    assert_equal 0, mq.matchings.size, "a"
    
    m = FactoryGirl.create(:matching)
    m.question = nil
    m.save!
    
    mq.matchings << m
    
    assert_equal 1, mq.matchings.size, "b"
    
    assert_equal m, mq.matchings.first, "c"
    
    m2 = FactoryGirl.create(:matching)
    m2.question = nil
    m2.save!
    
    mq.matchings << m2
    
    assert_equal 2, mpq.matchings.size
    
    assert_equal m2, mq.matchings.last
  end
  
  test "can't add matchings to a published question" do
    mq = make_matching_question(:publish => true)
    m = FactoryGirl.build(:matching)
    m.question = nil
    m.save!

    m.question = mq
    assert !m.save
    assert !m.errors.empty?
    m.errors.clear
    
    mq.matchings << m
    
    assert !m.errors.empty?
  end
  
  test "can't remove matchings from a published question" do
    mq = make_matching_question
    m = FactoryGirl.build(:matching)
    u = FactoryGirl.create(:user)
    m.question = mq
    m.save!
    mq.publish!(u)

    m.question = nil
    assert !m.save
    assert !m.errors.empty?
    assert_equal mq, m.question
    m.errors.clear
    
    mq2.matchings << m
    
    assert !m.errors.empty?
    assert_equal mq, m.question
  end
  
  test "normal publish" do
    mq = FactoryGirl.create(:matching_question)
    m = FactoryGirl.create(:matching)
    m2 = FactoryGirl.create(:matching)
    m3 = FactoryGirl.create(:matching)
    
    mq.matchings << m << m2 << m3
    
    user = FactoryGirl.create(:user)
    mq.set_initial_question_roles(user)
    
    assert mq.ready_to_be_published?

    assert !mq.is_published?
    
    assert_nothing_raised{ mq.publish!(user) }
    
    assert mq.errors.empty?    
    
    assert mq.is_published?
  end
  
  test "bad publish" do
    mq = FactoryGirl.create(:matching_question)
    m = FactoryGirl.create(:matching)
    m2 = FactoryGirl.create(:matching)
    m3 = FactoryGirl.create(:matching)
    
    m2.content = ""
    m2.save!
    
    mq.matchings << m << m2 << m3
    
    user = FactoryGirl.create(:user)
    mq.set_initial_question_roles(user)
    
    assert !mq.ready_to_be_published?

    assert !mq.is_published?
    
    assert mq.publish!(user).nil?

    assert !mq.is_published?
  end
  
  test "content copy" do
    mq = FactoryGirl.create(:matching_question)
    m = FactoryGirl.create(:matching)
    m2 = FactoryGirl.create(:matching)
    m3 = FactoryGirl.create(:matching)
    
    mq.matchings << m << m2 << m3
    
    pre_copy_time = Time.now

    sleep 1 # second
    
    kopy = mq.content_copy
    
    assert_equal kopy.matchings.size, mq.matchings.size, "a"
    
    (0..kopy.matchings.size-1).each do |ii|
      assert_equal kopy.matchings[ii].content, 
                   mq.matchings[ii].content, "b#{ii}"
    end
    
    kopy.save!
    
    # Make sure original didnt' change
    assert mq.matchings[0].updated_at < pre_copy_time, "c"
  end
end
