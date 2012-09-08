# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ListMembersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @member = FactoryGirl.create(:user)
    @list_member = FactoryGirl.create(:list_member, :user => @member)
  end

  test "should not create list_member not logged in" do
    assert_difference('ListMember.count', 0) do
      post :create, :list_member => {:username => @user.username}, :list_id => @list_member.list_id
    end
    assert_redirected_to login_path
  end

  test "should not create list_member not authorized" do
    sign_in @user
    assert_difference('ListMember.count', 0) do
      post :create, :list_member => {:username => @user.username}, :list_id => @list_member.list_id
    end
    assert_response(403)
  end

  test "should create list_member" do
    sign_in @member
    assert_difference('ListMember.count') do
      post :create, :list_member => {:username => @user.username}, :list_id => @list_member.list_id
    end
    assert_redirected_to list_path(@list_member.list)
  end

  test "should not destroy list_member not logged in" do
    assert_difference('ListMember.count', 0) do
      delete :destroy, :id => @list_member.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy list_member not authorized" do
    sign_in @user
    assert_difference('ListMember.count', 0) do
      delete :destroy, :id => @list_member.to_param
    end
    assert_response(403)
  end

  test "should destroy list_members" do
    sign_in @member
    @list_member2 = FactoryGirl.create(:list_member, :list => @list_member.list)

    assert_difference('ListMember.count', -1) do
      delete :destroy, :id => @list_member2.to_param
    end
    assert_redirected_to list_path(@list_member.list)

    assert_difference('ListMember.count', -1) do
      delete :destroy, :id => @list_member.to_param
    end
    assert_redirected_to lists_path
  end

  test "should not make_default list_member not logged in" do
    put :make_default, :list_member_id => @list_member.to_param
    assert_redirected_to login_path
  end

  test "should not make_default list_member not authorized" do
    sign_in @user
    put :make_default, :list_member_id => @list_member.to_param
    assert_response(403)
  end

  test "should make_default list_member" do
    sign_in @member
    list_member = FactoryGirl.create(:list_member, :user => @member)
    put :make_default, :list_member_id => list_member.to_param
    assert_redirected_to lists_path
  end
end
