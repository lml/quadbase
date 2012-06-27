# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionPartsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @qp1 = FactoryGirl.create(:question_part, :order => 1)
    @multipart_question = @qp1.multipart_question
    @qp2 = FactoryGirl.create(:question_part, :order => 2,
                                          :multipart_question => @multipart_question)
    ProjectQuestion.create(:question => @multipart_question,
                           :project => Project.default_for_user!(@user))
  end

  test "should destroy question_part" do
    sign_in @user
    assert_difference('QuestionPart.count', -1) do
      delete :destroy, :id => @qp1.id
    end
    assert_redirected_to edit_question_path(@multipart_question)
  end

  test "should sort question_parts" do
    sign_in @user
    assert_equal @qp1.order, 1
    assert_equal @qp2.order, 2
    post :sort, :part => [@qp2.to_param, @qp1.to_param]
    assert_equal @qp1.reload.order, 2
    assert_equal @qp2.reload.order, 1
    assert_redirected_to edit_question_path(@multipart_question)
  end

  test "should unlock question part" do
    sign_in @user

    qs = FactoryGirl.create(:question_setup, :content => "Something")
    pq1 = make_simple_question(:published => true, :question_setup => qs)
    pqp1 = FactoryGirl.create(:question_part, :order => 1, :child_question => pq1)
    multipart_question2 = pqp1.multipart_question
    multipart_question2.question_setup = qs
    multipart_question2.save!
    pq2 = make_simple_question(:published => true, :question_setup => qs)
    pqp2 = FactoryGirl.create(:question_part, :order => 2, :child_question => pq2,
                                          :multipart_question => multipart_question2)
    ProjectQuestion.create(:question => multipart_question2,
                           :project => Project.default_for_user!(@user))
    multipart_question2.reload

    assert !multipart_question2.setup_is_changeable?
    assert multipart_question2.child_questions.first.is_published?
    assert multipart_question2.child_questions.second.is_published?

    put :unlock, :question_part_id => pqp1.id
    assert multipart_question2.reload
    assert !multipart_question2.setup_is_changeable?
    assert !multipart_question2.child_questions.first.is_published?
    assert multipart_question2.child_questions.second.is_published?
    assert_redirected_to edit_question_path(multipart_question2)

    put :unlock, :question_part_id => pqp2.id
    assert multipart_question2.reload
    assert multipart_question2.setup_is_changeable?
    assert !multipart_question2.child_questions.first.is_published?
    assert !multipart_question2.child_questions.second.is_published?
    assert_redirected_to edit_question_path(multipart_question2)
  end

end
