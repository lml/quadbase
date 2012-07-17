# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class MatchingTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test 'cannot modify matchings for published question' do
    m = FactoryGirl.create(:matching)
    mq = m.question
    assert !mq.is_published?
    assert m.save
    
    u = FactoryGirl.create(:user)
    assert mq.publish!(u)
    assert mq.is_published?
    assert !m.save
  end
end
