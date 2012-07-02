# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @project = Project.default_for_user!(@user)
  end

  test "should not get index not logged in" do
    get :index
    assert_redirected_to login_path
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:project_members)
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

  test "should not create project not logged in" do
    assert_difference('Project.count', 0) do
      post :create, :project => @project.attributes
    end
    assert_redirected_to login_path
  end

  test "should create project" do
    user_login
    assert_difference('Project.count') do
      post :create, :project => @project.attributes
    end
    assert_redirected_to project_path(assigns(:project))
  end

  test "should not show project not logged in" do
    get :show, :id => @project.to_param
    assert_redirected_to login_path
  end

  test "should not show project not authorized" do
    user_login
    get :show, :id => @project.to_param
    assert_response(403)
  end

  test "should show project" do
    sign_in @user
    get :show, :id => @project.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    get :edit, :id => @project.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not authorized" do
    user_login
    get :edit, :id => @project.to_param
    assert_response(403)
  end

  test "should get edit" do
    sign_in @user
    get :edit, :id => @project.to_param
    assert_response :success
  end

  test "should not update project not logged in" do
    put :update, :id => @project.to_param, :project => @project.attributes
    assert_redirected_to login_path
  end

  test "should not update project not authorized" do
    user_login
    put :update, :id => @project.to_param, :project => @project.attributes
    assert_response(403)
  end

  test "should update project" do
    sign_in @user
    put :update, :id => @project.to_param, :project => @project.attributes
    assert_redirected_to project_path(assigns(:project))
  end

  test "should not destroy project not logged in" do
    assert_difference('Project.count', 0) do
      delete :destroy, :id => @project.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy project not authorized" do
    user_login
    assert_difference('Project.count', 0) do
      delete :destroy, :id => @project.to_param
    end
    assert_response(403)
  end

  test "should destroy project" do
    sign_in @user
    assert_difference('Project.count', -1) do
      delete :destroy, :id => @project.to_param
    end
    assert_redirected_to projects_path
  end
end
