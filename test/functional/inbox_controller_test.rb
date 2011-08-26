# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class InboxControllerTest < ActionController::TestCase

  test "should not get index not logged in" do
    get :index
    assert_redirected_to login_path
  end

  test "should get index" do
    user_login
    get :index
    assert_response :success
  end

end
