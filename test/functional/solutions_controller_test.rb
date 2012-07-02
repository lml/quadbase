# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class SolutionsControllerTest < ActionController::TestCase

  setup do
    ContentParseAndCache.enable_test_parser = true
    @user = FactoryGirl.create(:user)
    @solution = FactoryGirl.create(:solution, :creator => @user)
    @question = @solution.question
    @project = Project.default_for_user!(@user)
    @project_question = FactoryGirl.create(:project_question, :project => @project, :question => @question)
    @published_question = make_simple_question(:method => :create, :published => true)
    @published_solution = FactoryGirl.create(:solution, :question => @published_question)
    @visible_published_solution = FactoryGirl.create(:solution, :question => @published_question,
                                                            :is_visible => true)
    ContentParseAndCache.enable_test_parser = false
  end

  test "should not get index not logged in" do
    get :index, :question_id => @question.to_param
    assert_response(403)
  end

  test "should not get index not authorized" do
    user_login
    get :index, :question_id => @question.to_param
    assert_response(403)
  end

  test "should get index published question" do
    get :index, :question_id => @published_question.to_param
    assert_response :success
  end

  test "should get index" do
    sign_in @user
    get :index, :question_id => @question.to_param
    assert_response :success
  end

  test "should not get new not logged in" do
    get :new, :question_id => @question.to_param
    assert_redirected_to login_path
  end

  test "should not get new not authorized" do
    user_login
    get :new, :question_id => @question.to_param
    assert_response(403)
  end

  test "should get new" do
    sign_in @user
    get :new, :question_id => @question.to_param
    assert_response :success
  end

  test "should get new published question" do
    user_login
    get :new, :question_id => @published_question.to_param
    assert_response :success
  end

  test "should not show solution not logged in" do
    get :show, :id => @solution.to_param
    assert_response(403)
  end

  test "should not show solution not authorized" do
    user_login
    get :show, :id => @solution.to_param
    assert_response(403)
  end

  test "should not show solution not visible" do
    user_login
    get :show, :id => @published_solution.to_param
    assert_response(403)
  end

  test "should show solution creator" do
    sign_in @user
    get :show, :id => @solution.to_param
    assert_response :success
  end

  test "should show visible solution published question" do
    get :show, :id => @visible_published_solution.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    get :edit, :id => @solution.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not authorized" do
    user_login
    get :edit, :id => @solution.to_param
    assert_response(403)
  end

  test "should get edit" do
    sign_in @user
    get :edit, :id => @solution.to_param
    assert_response :success
  end

  test "should not update solution not logged in" do
    put :update, :id => @solution.to_param, :solution => @solution.attributes
    assert_redirected_to login_path
  end

  test "should not update solution not authorized" do
    user_login
    put :update, :id => @solution.to_param, :solution => @solution.attributes
    assert_response(403)
  end

  test "should update solution" do
    sign_in @user
    put :update, :id => @solution.to_param, :solution => @solution.attributes
    assert_redirected_to question_solutions_path(@question)
  end

  test "should not destroy solution not logged in" do
    assert_difference('Solution.count', 0) do
      delete :destroy, :id => @solution.to_param
    end

    assert_redirected_to login_path
  end

  test "should not destroy solution not authorized" do
    user_login
    assert_difference('Solution.count', 0) do
      delete :destroy, :id => @solution.to_param
    end

    assert_response(403)
  end

  test "should destroy solution" do
    sign_in @user
    assert_difference('Solution.count', -1) do
      delete :destroy, :id => @solution.to_param
    end

    assert_redirected_to question_solutions_path(@question)
  end

end
