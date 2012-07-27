# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ListQuestionsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @question = FactoryGirl.create(:simple_question)
    @question2 = FactoryGirl.create(:simple_question)
    @list = List.default_for_user!(@user)
    @list_question = FactoryGirl.create(:list_question, :list => @list, :question => @question)
    @list_question2 = FactoryGirl.create(:list_question, :list => @list, :question => @question2)
    @published_question = make_simple_question(:method => :create, :published => true)
    @published_list_question = FactoryGirl.create(:list_question,
                                                   :question => @published_question)
  end

  test "should not move list_question not logged in" do
    list = FactoryGirl.create(:list, :members => [@user])
    assert @list.has_question?(@question)
    assert !list.has_question?(@question)
    put :move, :list_id => @list.to_param,
               :list_question_ids => [@list_question.to_param],
               :move => [list.to_param]
    assert_redirected_to login_path
    assert @list.has_question?(@question)
    assert !list.has_question?(@question)
  end

  test "should not move list_question not authorized" do
    user_login
    list = FactoryGirl.create(:list, :members => [@user])
    assert @list.has_question?(@question)
    assert !list.has_question?(@question)
    put :move, :list_id => @list.to_param,
               :list_question_ids => [@list_question.to_param],
               :move => [list.to_param]
    assert_response(403)
    assert @list.has_question?(@question)
    assert !list.has_question?(@question)
  end

  test "should move list_question" do
    sign_in @user
    list = FactoryGirl.create(:list, :members => [@user])
    assert @list.has_question?(@question), "a"
    assert !list.has_question?(@question), "b"
    put :move, :list_id => @list.to_param,
               :list_question_ids => [@list_question.to_param],
               :move => [list.to_param]
    assert_redirected_to list_path(@list), "c"
    @list.questions.reload
    assert !@list.has_question?(@question), "d"
    assert list.has_question?(@question), "e"
  end

  test "should not copy list_question not logged in" do
    list = FactoryGirl.create(:list, :members => [@user])
    assert !list.has_question?(@question)
    assert_difference('list.list_questions.count', 0) do
      put :copy, :list_id => @list.to_param,
                 :list_question_ids => [@list_question.to_param],
                 :copy => [list.to_param]
    end
    assert_redirected_to login_path
    assert !list.has_question?(@question)
  end

  test "should not copy list_question not authorized" do
    user_login
    list = FactoryGirl.create(:list, :members => [@user])
    assert !list.has_question?(@question)
    assert_difference('list.list_questions.count', 0) do
      put :copy, :list_id => @list.to_param,
                 :list_question_ids => [@list_question.to_param],
                 :copy => [list.to_param]
    end
    assert_response(403)
    assert !list.has_question?(@question)
  end

  test "should copy list_question" do
    sign_in @user
    list = FactoryGirl.create(:list, :members => [@user])
    assert !list.has_question?(@question)
    assert_difference('list.list_questions.count', 1) do
      put :copy, :list_id => @list.to_param,
                 :list_question_ids => [@list_question.to_param],
                 :copy => [list.to_param]
    end
    assert_redirected_to list_path(@list)
  end

  test "should copy list_question published question" do
    sign_in @user
    assert !@list.has_question?(@published_question)
    assert_difference('@list.list_questions.count', 1) do
      put :copy, :list_id => @published_list_question.list.to_param,
                 :list_question_ids => [@published_list_question.to_param],
                 :copy => [@list.to_param]
    end
    assert @list.list_questions.detect { |wq| wq.question.source_question == @published_question }
    assert_redirected_to list_path(@published_list_question.list)
  end

  test "should preview_publish list_questions" do
    sign_in @user
    question_ids = [@question.id, @question2.id]
    list_question_ids = [@list_question.to_param, @list_question2.to_param]
    put :preview_publish, :list_id => @list.to_param,
                          :list_question_ids => list_question_ids
    assert_response :success
  end

  test "should not destroy list_question not logged in" do
    assert_difference('ListQuestion.count', 0) do
      delete :destroy, :list_id => @list.to_param,
                       :list_question_ids => [@list_question.to_param]
    end
    assert_redirected_to login_path
  end

  test "should not destroy list_question not authorized" do
    user_login
    assert_difference('ListQuestion.count', 0) do
      delete :destroy, :list_id => @list.to_param,
                       :list_question_ids => [@list_question.to_param]
    end
    assert_response(403)
  end

  test "should destroy list_question" do
    sign_in @user
    assert_difference('ListQuestion.count', -1) do
      delete :destroy, :list_id => @list.to_param,
                       :list_question_ids => [@list_question.to_param]
    end
    assert_redirected_to list_path(@list)
  end
end
