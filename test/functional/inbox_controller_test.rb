# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

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
