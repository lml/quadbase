# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign question, creator and content_html" do
    question = FactoryGirl.create(:simple_question)
    creator = FactoryGirl.create(:user)
    content_html = "Some content"
    s = Solution.new(:question => question,
                     :creator => creator,
                     :content_html => content_html)
    assert s.question != question
    assert s.creator != creator
    assert s.content_html != content_html
  end

  test "visible_for" do
    q = FactoryGirl.create(:simple_question)
    u = FactoryGirl.create(:user)
    u2 = FactoryGirl.create(:user)

    s0 = Solution.new
    s0.question = q
    s0.creator = u
    s0.save!

    s1 = Solution.new
    s1.question = q
    s1.creator = u2
    s1.save!

    s2 = Solution.new(:is_visible => true)
    s2.question = q
    s2.creator = u2
    s2.save!

    q.reload

    sa0 = q.solutions
    sa1 = sa0.visible_for(u)

    assert sa0.size == 3
    assert sa1.size == 2

    assert sa1[0] == s0
    assert sa1[1] == s2
  end

end
