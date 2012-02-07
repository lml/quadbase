# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class AdminControllerTest < ActionController::TestCase

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

end
