# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class QuestionPartsControllerTest < ActionController::TestCase

  setup do
    @user = Factory.create(:user)
    @qp1 = Factory.create(:question_part, :order => 1)
    @multipart_question = @qp1.multipart_question
    @qp2 = Factory.create(:question_part, :order => 2,
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

end
