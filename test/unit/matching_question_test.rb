# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class MatchingQuestionTest < ActiveSupport::TestCase

  test "create" do
    mq = FactoryGirl.create(:matching_question)
    assert_not_nil mq
  end

  test "matchings" do
    mq = FactoryGirl.create(:matching_question_with_matchings)
    m = mq.matchings.first
    
    assert !m.question.matchings.empty?, 'a'
    
    m2 = FactoryGirl.build(:matching)

    assert_difference('mq.matchings.count') do
      mq.matchings << m2
      assert m2.errors.empty?
    end
  end

  test "add_matchings" do
    mq = FactoryGirl.create(:matching_question)
    
    assert_equal 0, mq.matchings.size, "a"
    
    m = FactoryGirl.build(:matching)
    
    mq.matchings << m
    
    assert_equal 1, mq.matchings.size, "b"
    
    assert_equal m, mq.matchings.first, "c"
    
    m2 = FactoryGirl.build(:matching)
    
    mq.matchings << m2
    
    assert_equal 2, mq.matchings.size
    
    assert_equal m2, mq.matchings.last
  end
  
  test "can't add matchings to a published question" do
    mq = make_matching_question(:publish => true)
    m = FactoryGirl.build(:matching)
    m.question = nil

    m.question = mq
    assert !m.save
    assert !m.errors.empty?
    m.errors.clear
    
    assert_difference('mq.matchings.count', 0) do
      mq.matchings << m
      assert !m.errors.empty?
    end
  end
  
  test "normal publish" do
    mq = FactoryGirl.create(:matching_question_with_matchings)
    
    user = FactoryGirl.create(:user)
    mq.set_initial_question_roles(user)
    
    assert mq.ready_to_be_published?

    assert !mq.is_published?
    
    assert_nothing_raised{ mq.publish!(user) }
    
    assert mq.errors.empty?    
    
    assert mq.is_published?
  end
  
  test "bad publish" do
    mq = FactoryGirl.create(:matching_question_with_matchings)
    
    m = mq.matchings.last
    m.content = ''
    m.save!
    
    user = FactoryGirl.create(:user)
    mq.set_initial_question_roles(user)
    
    assert !mq.ready_to_be_published?

    assert !mq.is_published?
    
    mq.publish!(user)

    assert !mq.is_published?
  end
  
  test "content copy" do
    mq = FactoryGirl.create(:matching_question_with_matchings)
    
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
