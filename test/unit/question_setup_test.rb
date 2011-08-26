# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class QuestionSetupTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign content_html" do
    content_html = "Some content"
    qs = QuestionSetup.new(:content_html => content_html)
    assert qs.content_html != content_html
  end
  
  test "content copy" do
    qs0 = Factory.create(:question_setup)
    qs1 = qs0.content_copy
    assert_equal qs0.content, qs1.content
    assert_not_equal qs0, qs1
  end

end
