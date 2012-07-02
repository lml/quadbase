# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class MessagesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @message = FactoryGirl.create(:message)
    @message.comment_thread.subscribe!(@user)
  end

  test "should not get new not logged in" do
    get :new
    assert_redirected_to login_path
  end

  test "should get new" do
    user_login
    get :new
    assert_redirected_to message_path(assigns[:message])
  end

  test "should not show message not logged in" do
    get :show, :id => @message.to_param
    assert_redirected_to login_path
  end

  test "should not show message not authorized" do
    user_login
    get :show, :id => @message.to_param
    assert_response(403)
  end

  test "should show message" do
    sign_in @user
    get :show, :id => @message.to_param
    assert_response :success
  end

  test "should not update message not logged in" do
    put :update, :id => @message.to_param, :message => @message.attributes
    assert_redirected_to login_path
  end

  test "should not update message not authorized" do
    user_login
    put :update, :id => @message.to_param, :message => @message.attributes
    assert_response(403)
  end

  test "should update message" do
    sign_in @user
    put :update, :id => @message.to_param, :message => @message.attributes
    assert_redirected_to message_path(assigns(:message))
  end

end
