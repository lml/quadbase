require 'test_helper'

class MatchItemTest < ActiveSupport::TestCase
  fixtures
  self.use_transactional_fixtures = true

  test 'cannot modify match_items for published question' do
    mq = FactoryGirl.create(:matching_question_with_match_items)
    m = mq.match_items.first
    m2 = mq.match_items.last
    
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
  
  test 'cannot move match_items to another question' do
    mq = FactoryGirl.create(:matching_question_with_match_items)
    mq2 = FactoryGirl.create(:matching_question)
    m = mq.match_items.first
    m2 = mq.match_items.last
    
    assert m.save
    assert m2.save
    
    m.question = mq2
    m2.question = mq2
    
    assert !m.save
    assert !m2.save
  end
end
