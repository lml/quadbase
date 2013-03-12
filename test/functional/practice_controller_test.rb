require 'test_helper'

class PracticeControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get next" do
    get :next
    assert_response :success
  end

  test "should get prev" do
    get :prev
    assert_response :success
  end

  test "should get submit_answer" do
    get :submit_answer
    assert_response :success
  end

end
