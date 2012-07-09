# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class AnnouncementsControllerTest < ActionController::TestCase
  setup do
    @announcement = FactoryGirl.create(:announcement)
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
    assert_not_nil assigns(:announcements)
  end

  test "should not get new not logged in" do
    get :new
    assert_redirected_to login_path
  end

  test "should not get new not admin" do
    user_login
    get :new
    assert_redirected_to home_path
  end

  test "should get new" do
    admin_login
    get :new
    assert_response :success
  end

  test "should not create announcement not logged in" do
    assert_difference('Announcement.count', 0) do
      post :create, :announcement => @announcement.attributes
    end

    assert_redirected_to login_path
  end

  test "should not create announcement not admin" do
    user_login

    assert_difference('Announcement.count', 0) do
      post :create, :announcement => @announcement.attributes
    end

    assert_redirected_to home_path
  end

  test "should create announcement" do
    admin_login

    assert_difference('Announcement.count') do
      post :create, :announcement => @announcement.attributes
    end

    assert_redirected_to announcements_path
  end

  test "should not show announcement not logged in" do
    get :show, :id => @announcement.to_param
    assert_redirected_to login_path
  end

  test "should not show announcement not admin" do
    user_login
    get :show, :id => @announcement.to_param
    assert_redirected_to home_path
  end

  test "should show announcement" do
    admin_login
    get :show, :id => @announcement.to_param
    assert_response :success
  end

  test "should not destroy announcement not logged in" do
    assert_difference('Announcement.count', 0) do
      delete :destroy, :id => @announcement.to_param
    end

    assert_redirected_to login_path
  end

  test "should not destroy announcement not admin" do
    user_login

    assert_difference('Announcement.count', 0) do
      delete :destroy, :id => @announcement.to_param
    end

    assert_redirected_to home_path
  end

  test "should destroy announcement" do
    admin_login

    assert_difference('Announcement.count', -1) do
      delete :destroy, :id => @announcement.to_param
    end

    assert_redirected_to announcements_path
  end
end
