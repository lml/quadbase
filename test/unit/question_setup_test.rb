# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

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
