require 'test_helper'

class QtImportControllerTest < ActionController::TestCase
	
  test "should_show_form" do
    get :new
    assert_response :success
  end
end
