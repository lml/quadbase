# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @list = List.default_for_user!(@user)
  end

  test "should get index not logged in" do
    get :index
    assert_response :success
    assert_empty assigns(:lists)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_empty assigns(:lists)
  end

  test "should not get new not logged in" do
    get :new
    assert_redirected_to login_path
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should not create list not logged in" do
    assert_difference('List.count', 0) do
      post :create, :list => @list.attributes
    end
    assert_redirected_to login_path
  end

  test "should create list" do
    user_login
    assert_difference('List.count') do
      post :create, :list => @list.attributes
    end
    assert_redirected_to list_path(assigns(:list))
  end

  test "should auto default new list if no other default" do
    sign_in @user
    assert_difference('List.count', -1) do
      delete :destroy, :id => @list.to_param
    end
    assert @user.lists.empty?
    assert_difference('List.count') do
      post :create, :list => @list.attributes
    end
    assert @user.lists.last.is_default_for_user?(@user)
    assert_redirected_to list_path(assigns(:list))
    assert_difference('List.count') do
      post :create, :list => @list.attributes
    end
    assert !@user.lists.last.is_default_for_user?(@user)
    assert_redirected_to list_path(assigns(:list))
  end

  test "should not show list not logged in" do
    get :show, :id => @list.to_param
    assert_response(403)
  end

  test "should not show list not authorized" do
    user_login
    get :show, :id => @list.to_param
    assert_response(403)
  end

  test "should show list" do
    sign_in @user
    get :show, :id => @list.to_param
    assert_response :success
  end

  test "should show public list" do
    @list.is_public = true
    @list.save!
    get :show, :id => @list.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    get :edit, :id => @list.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not authorized" do
    user_login
    get :edit, :id => @list.to_param
    assert_response(403)
  end

  test "should get edit" do
    sign_in @user
    get :edit, :id => @list.to_param
    assert_response :success
  end

  test "should not update list not logged in" do
    put :update, :id => @list.to_param, :list => @list.attributes
    assert_redirected_to login_path
  end

  test "should not update list not authorized" do
    user_login
    put :update, :id => @list.to_param, :list => @list.attributes
    assert_response(403)
  end

  test "should update list" do
    sign_in @user
    put :update, :id => @list.to_param, :list => @list.attributes
    assert_redirected_to list_path(assigns(:list))
  end

  test "should not destroy list not logged in" do
    assert_difference('List.count', 0) do
      delete :destroy, :id => @list.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy list not authorized" do
    user_login
    assert_difference('List.count', 0) do
      delete :destroy, :id => @list.to_param
    end
    assert_response(403)
  end

  test "should destroy list" do
    sign_in @user
    assert_difference('List.count', -1) do
      delete :destroy, :id => @list.to_param
    end
    assert_redirected_to lists_path
  end

  test "should not get practice not logged in" do
    get :practice, :id => @list.to_param, :format => :json
    assert_response(401)
  end

  test "should not get practice not authorized" do
    user_login
    get :practice, :id => @list.to_param, :format => :json
    assert_response(403)
  end

  test "should get practice" do
    sign_in @user
    get :practice, :id => @list.to_param, :format => :json
    assert_response :success
  end
end
