# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectMembersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @member = FactoryGirl.create(:user)
    @project_member = FactoryGirl.create(:project_member, :user => @member)
  end

  test "should not create project_member not logged in" do
    assert_difference('ProjectMember.count', 0) do
      post :create, :project_member => {:username => @user.username}, :project_id => @project_member.project_id
    end
    assert_redirected_to login_path
  end

  test "should not create project_member not authorized" do
    sign_in @user
    assert_difference('ProjectMember.count', 0) do
      post :create, :project_member => {:username => @user.username}, :project_id => @project_member.project_id
    end
    assert_response(403)
  end

  test "should create project_member" do
    sign_in @member
    assert_difference('ProjectMember.count') do
      post :create, :project_member => {:username => @user.username}, :project_id => @project_member.project_id
    end
    assert_redirected_to project_path(@project_member.project)
  end

  test "should not destroy project_member not logged in" do
    assert_difference('ProjectMember.count', 0) do
      delete :destroy, :id => @project_member.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy project_member not authorized" do
    sign_in @user
    assert_difference('ProjectMember.count', 0) do
      delete :destroy, :id => @project_member.to_param
    end
    assert_response(403)
  end

  test "should destroy project_members" do
    sign_in @member
    @project_member2 = FactoryGirl.create(:project_member, :project => @project_member.project)

    assert_difference('ProjectMember.count', -1) do
      delete :destroy, :id => @project_member2.to_param
    end
    assert_redirected_to project_path(@project_member.project)

    assert_difference('ProjectMember.count', -1) do
      delete :destroy, :id => @project_member.to_param
    end
    assert_redirected_to projects_path
  end

  test "should not make_default project_member not logged in" do
    put :make_default, :project_member_id => @project_member.to_param
    assert_redirected_to login_path
  end

  test "should not make_default project_member not authorized" do
    sign_in @user
    put :make_default, :project_member_id => @project_member.to_param
    assert_response(403)
  end

  test "should make_default project_member" do
    sign_in @member
    put :make_default, :project_member_id => @project_member.to_param
    assert_redirected_to projects_path
  end
end
