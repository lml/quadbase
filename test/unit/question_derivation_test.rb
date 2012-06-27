# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionDerivationTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "must have source_question_id, derived_question_id, deriver_id" do
    qd = FactoryGirl.create(:question_derivation)
    qd.reload
    qd.save!
    qd.source_question_id = nil
    assert !qd.save
    qd.reload
    qd.derived_question_id = nil
    assert !qd.save
    qd.reload
    qd.deriver_id = nil
    assert !qd.save
  end

  test "basic" do
    # test the attributes, validations
    qd = QuestionDerivation.new
    assert !qd.save
    qd = FactoryGirl.build(:question_derivation)
    assert qd.save
    qd2 = FactoryGirl.build(:question_derivation)
    qd2.derived_question = qd.derived_question
    assert !qd2.save
  end
end
