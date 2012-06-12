# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @solution = FactoryGirl.create(:solution, :is_visible => true)
    @question = @solution.question
    @project = Project.default_for_user!(@user)
    @project_question = FactoryGirl.create(:project_question, :project => @project, :question => @question)
    @published_question = make_simple_question(:method => :create, :published => true)
    @published_solution = FactoryGirl.create(:solution, :question => @published_question,
                                                    :is_visible => true)
  end

  test "should not vote up not logged in" do
    assert_difference('Vote.positive.count', 0) do
      post :up, :solution_id => @solution.to_param
    end
    assert_redirected_to login_path
  end

  test "should not vote up not authorized" do
    user_login
    assert_difference('Vote.positive.count', 0) do
      post :up, :solution_id => @solution.to_param
    end
    assert_response(403)
  end

  test "should vote up" do
    sign_in @user
    assert_difference('Vote.positive.count') do
      post :up, :solution_id => @solution.to_param
    end
    assert_redirected_to solution_path(@solution)
  end

  test "should vote up published question" do
    user_login
    assert_difference('Vote.positive.count') do
      post :up, :solution_id => @published_solution.to_param
    end
    assert_redirected_to solution_path(@published_solution)
  end

  test "should not vote down not logged in" do
    assert_difference('Vote.negative.count', 0) do
      post :down, :solution_id => @solution.to_param
    end
    assert_redirected_to login_path
  end

  test "should not vote down not authorized" do
    user_login
    assert_difference('Vote.negative.count', 0) do
      post :down, :solution_id => @solution.to_param
    end
    assert_response(403)
  end

  test "should vote down" do
    sign_in @user
    assert_difference('Vote.negative.count') do
      post :down, :solution_id => @solution.to_param
    end
    assert_redirected_to solution_path(@solution)
  end

  test "should vote down published question" do
    user_login
    assert_difference('Vote.negative.count') do
      post :down, :solution_id => @published_solution.to_param
    end
    assert_redirected_to solution_path(@published_solution)
  end

end
