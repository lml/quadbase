#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QtImportControllerTest < ActionController::TestCase
  
	setup do 
		@user = Factory.create(:user)
		@file1 = fixture_file_upload("/files/spqr3.xml", 'xml')	
		@content = 'SPQR'
	end

	test "should get new" do
		user_login
		get :new
		assert_response :success
	end

	test "should not get new not logged in" do
		get :new
		assert_redirected_to login_path
	end

	test "should import" do
		sign_in @user
		post :create, :file => @file1, :content_types => @content
		@project = Project.find_by_name("Import")
		assert(@project.is_member?(@user), "user is member of project")
		assert_response :success
	end
end
