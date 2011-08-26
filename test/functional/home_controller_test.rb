# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

end
