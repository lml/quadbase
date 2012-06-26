# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end

  test "should not get index not logged in" do
    get :index
    assert_redirected_to login_path
  end

  test "should not get index not admin" do
    user_login
    get :index
    assert_redirected_to home_path
  end

  test "should get index" do
    admin_login
    get :index
    assert_response :success
  end

  test "should not get show not logged in" do
    get :show, :id => @user.to_param
    assert_redirected_to login_path
  end

  test "should get show" do
    user_login
    get :show, :id => @user.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    get :edit, :id => @user.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not admin" do
    user_login
    get :edit, :id => @user.to_param
    assert_redirected_to home_path
  end

  test "should get edit" do
    admin_login
    get :edit, :id => @user.to_param
    assert_response :success
  end

  test "should not update user not logged in" do
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to login_path
  end

  test "should not update user not admin" do
    user_login
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to home_path
  end

  test "should update user" do
    admin_login
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should get help" do
    user_login
    get :help, :user_id => @user.to_param
    assert_response :success
  end

  test "should search users" do
    user_login
    post :search, :text_query => "Some Query",
                  :selected_type => "All"
    assert_response :success
    assert_not_nil assigns(:users)
  end

end
