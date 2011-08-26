# Copyright (c) 2011 Rice University.  All rights reserved.

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

  test "should get dialog" do
    get :dialog, :partial_name => "multipart"
    assert_response :success
  end

end
