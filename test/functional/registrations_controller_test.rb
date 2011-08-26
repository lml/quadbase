# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @admin = Factory.create(:user)
    @user = Factory.create(:user)
  end

  test "should not create user invalid recaptcha" do
    user = Factory.build(:user)
    assert_difference('User.count', 0) do
      post :create, :user => user.attributes
    end
    assert !User.find_by_id(user.id)
    assert_response :success
  end

  test "should disable user" do
    sign_in @user
    assert !@user.is_disabled?
    delete :destroy
    @user = User.find(@user.id)
    assert @user.is_disabled?
    assert_redirected_to root_path
  end

end
