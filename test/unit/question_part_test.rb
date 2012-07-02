# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionPartTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "unlock!" do
    user = FactoryGirl.create(:user)
    
    qs = FactoryGirl.create(:question_setup)
    qs.content = "Something"
    qs.save!

    mpq = FactoryGirl.create(:multipart_question, :question_setup => qs)

    FactoryGirl.create(:project_question, :project => Project.default_for_user!(user), :question => mpq)
    sq = FactoryGirl.create(:project_question, :project => Project.default_for_user!(user)).question
    psq = make_simple_question(:published => true, :question_setup => qs)

    sq.question_setup = qs
    sq.save!

    assert mpq.add_parts([sq, psq])
    assert mpq.errors.empty?

    assert mpq.reload

    assert !mpq.child_question_parts.first.child_question.is_published?
    assert mpq.child_question_parts.second.child_question.is_published?

    assert !mpq.question_setup.content_change_allowed?

    assert !mpq.child_question_parts.first.unlock!(user)
    assert !mpq.question_setup.content_change_allowed?

    assert mpq.child_question_parts.second.unlock!(user)
    assert mpq.reload
    assert mpq.question_setup.content_change_allowed?
    assert_equal mpq.question_setup.content, qs.content
    assert !mpq.child_question_parts.second.child_question.is_published?
  end
end
