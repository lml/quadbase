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
    qs0 = FactoryGirl.create(:question_setup)
    qs1 = qs0.content_copy
    assert_equal qs0.content, qs1.content
    assert_not_equal qs0, qs1
  end

  test "merge" do
    qs = FactoryGirl.create(:question_setup)
    qs.content = "Something"
    qs_blank = FactoryGirl.create(:question_setup)
    qs_blank.content = ""
    qs2 = FactoryGirl.create(:question_setup)
    qs2.content = "Something"
    qs_different = FactoryGirl.create(:question_setup)
    qs_different.content = "Something else"

    qs.save!
    qs_blank.save!
    qs2.save!

    assert_equal qs.merge(qs_blank), qs
    assert_equal qs_blank.merge(qs), qs

    assert_equal qs.merge(qs2), qs2
    assert_equal qs2.merge(qs), qs

    assert_equal qs2.merge(qs_blank), qs2
    assert_equal qs_blank.merge(qs2), qs2

    assert_nil qs.merge(qs_different)
    assert_nil qs_different.merge(qs)

    pq = make_simple_question(:published => true, :question_setup => qs)
    pq2 = make_simple_question(:published => true, :question_setup => qs2)

    qs.reload
    qs2.reload

    assert_nil qs.merge(qs2)
    assert_nil qs2.merge(qs)
  end

end
