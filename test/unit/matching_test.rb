# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class MatchingTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test 'cannot modify matchings for published question' do
    mq = FactoryGirl.create(:matching_question_with_matchings)
    m = mq.matchings.first
    m2 = mq.matchings.last
    
    assert !mq.is_published?
    assert m.save
    assert m2.save
    
    user = FactoryGirl.create(:user)
    mq.set_initial_question_roles(user)
    
    assert_nothing_raised{ mq.publish!(user) }
    
    assert mq.is_published?
    assert !m.save
    assert !m2.save
  end
  
  test 'cannot move matchings to another question' do
    mq = FactoryGirl.create(:matching_question_with_matchings)
    mq2 = FactoryGirl.create(:matching_question)
    m = mq.matchings.first
    m2 = mq.matchings.last
    
    assert m.save
    assert m2.save
    
    m.question = mq2
    m2.question = mq2
    
    assert !m.save
    assert !m2.save
  end
end
