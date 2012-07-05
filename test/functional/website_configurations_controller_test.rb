# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class WebsiteConfigurationsControllerTest < ActionController::TestCase

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
    assert_not_nil assigns(:website_configurations)
  end

  test "should not get edit not logged in" do
    get :edit
    assert_redirected_to login_path
  end

  test "should not get edit not admin" do
    user_login
    get :edit
    assert_redirected_to home_path
  end

  test "should get edit" do
    admin_login
    get :edit
    assert_response :success
  end

  test "should not update website_configuration not logged in" do
    assert !WebsiteConfiguration.get_value("in_maintenance")
    WebsiteConfiguration.reset_column_information
    put :update, "in_maintenance" => true
    assert !WebsiteConfiguration.get_value("in_maintenance")
    assert_redirected_to login_path
  end

  test "should not update website_configuration not admin" do
    user_login
    assert !WebsiteConfiguration.get_value("in_maintenance")
    WebsiteConfiguration.reset_column_information
    put :update, "in_maintenance" => true
    assert !WebsiteConfiguration.get_value("in_maintenance")
    assert_redirected_to home_path
  end

  test "should update website_configuration" do
    admin_login
    assert !WebsiteConfiguration.get_value("in_maintenance")
    WebsiteConfiguration.reset_column_information
    put :update, "in_maintenance" => true
    assert WebsiteConfiguration.get_value("in_maintenance")
    assert_redirected_to website_configurations_path(assigns(:website_configuration))
    put :update, "in_maintenance" => false
    assert !WebsiteConfiguration.get_value("in_maintenance")
    assert_redirected_to website_configurations_path(assigns(:website_configuration))
  end

end
