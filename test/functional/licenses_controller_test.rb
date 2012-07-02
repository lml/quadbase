# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class LicensesControllerTest < ActionController::TestCase

  setup do
    License.delete_all
    assert_equal 0, License.count
    @license = FactoryGirl.build(:license)
  end

  test "should not get index not logged in" do
    @license.save!
    get :index
    assert_redirected_to login_path
  end

  test "should not get index not admin" do
    @license.save!
    user_login
    get :index
    assert_redirected_to home_path
  end

  test "should get index" do
    @license.save!
    admin_login
    get :index
    assert_response :success
    assert_not_nil assigns(:licenses)
  end

  test "should not get new not logged in" do
    get :new
    assert_redirected_to login_path
  end

  test "should not get new not admin" do
    user_login
    get :new
    assert_redirected_to home_path
  end

  test "should get new" do
    admin_login
    get :new
    assert_response :success
  end

  test "should not create license not logged in" do
    assert_difference('License.count', 0) do
      post :create, :license => @license.attributes
    end
    assert_redirected_to login_path
  end

  test "should not create license not admin" do
    user_login
    assert_difference('License.count', 0) do
      post :create, :license => @license.attributes
    end
    assert_redirected_to home_path
  end

  test "should create only one license" do
    admin_login
    assert_difference('License.count') do
      post :create, :license => @license.attributes
    end
    assert_redirected_to license_path(assigns(:license))
    @license2 = FactoryGirl.build(:license)
    assert_difference('License.count', 0) do
      post :create, :license => @license2.attributes
    end
  end

  test "should show license" do
    @license.save!
    get :show, :id => @license.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    @license.save!
    get :edit, :id => @license.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not admin" do
    @license.save!
    user_login
    get :edit, :id => @license.to_param
    assert_redirected_to home_path
  end

  test "should get edit" do
    @license.save!
    admin_login
    get :edit, :id => @license.to_param
    assert_response :success
  end

  test "should not update license not logged in" do
    @license.save!
    put :update, :id => @license.to_param, :license => @license.attributes
    assert_redirected_to login_path
  end

  test "should not update license not admin" do
    @license.save!
    user_login
    put :update, :id => @license.to_param, :license => @license.attributes
    assert_redirected_to home_path
  end

  test "should update license" do
    @license.save!
    admin_login
    put :update, :id => @license.to_param, :license => @license.attributes
    assert_redirected_to license_path(assigns(:license))
  end

  test "should not destroy license not logged in" do
    @license.save!
    assert_difference('License.count', 0) do
      delete :destroy, :id => @license.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy license not admin" do
    @license.save!
    user_login
    assert_difference('License.count', 0) do
      delete :destroy, :id => @license.to_param
    end
    assert_redirected_to home_path
  end

  test "should destroy license" do
    @license.save!
    admin_login
    assert_difference('License.count', -1) do
      delete :destroy, :id => @license.to_param
    end
    assert_redirected_to licenses_path
  end

  test "should not make_default license not logged in" do
    @license.save!
    put :make_default, :selected_license => @license.to_param
    assert_redirected_to login_path
  end

  test "should not make_default license not admin" do
    @license.save!
    user_login
    put :make_default, :selected_license => @license.to_param
    assert_redirected_to home_path
  end

  test "should make_default license" do
    @license.save!
    admin_login
    put :make_default, :selected_license => @license.to_param
    assert_redirected_to licenses_path
  end

end
