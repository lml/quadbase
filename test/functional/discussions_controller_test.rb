# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @discussion = FactoryGirl.create(:discussion)
    @discussion.comment_thread.subscribe!(@user)
  end

  test "should not get new not logged in" do
    get :new
    assert_redirected_to login_path
  end

  test "should get new" do
    user_login
    get :new
    assert_redirected_to discussion_path(assigns[:discussion])
  end

  test "should not show discussion not logged in" do
    get :show, :id => @discussion.to_param
    assert_redirected_to login_path
  end

  test "should not show discussion not authorized" do
    user_login
    get :show, :id => @discussion.to_param
    assert_response(403)
  end

  test "should show discussion" do
    sign_in @user
    get :show, :id => @discussion.to_param
    assert_response :success
  end

  test "should not update discussion not logged in" do
    put :update, :id => @discussion.to_param, :discussion => @discussion.attributes
    assert_redirected_to login_path
  end

  test "should not update discussion not authorized" do
    user_login
    put :update, :id => @discussion.to_param, :discussion => @discussion.attributes
    assert_response(403)
  end

  test "should update discussion" do
    sign_in @user
    put :update, :id => @discussion.to_param, :discussion => @discussion.attributes
    assert_redirected_to discussion_path(assigns(:discussion))
  end

end
