# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class HelpControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

  test "should get beta" do
    get :beta
    assert_response :success
  end

  test "should get authoring" do
    get :authoring
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get legal" do
    get :legal_faq
    assert_response :success
  end

  test "should get topic" do
    get :topic, :topic_name => "discussions"
    assert_response :success
  end

end
