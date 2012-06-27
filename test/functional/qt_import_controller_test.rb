#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QtImportControllerTest < ActionController::TestCase
  
	setup do 
		@user = FactoryGirl.create(:user)
		@file1 = fixture_file_upload("/files/spqr3.xml", 'xml')	
		@file2 = fixture_file_upload("/files/check_icon_v1.png", 'png')
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
		post :create, :file => @file1, :content_type => @content
		@project = Project.find_by_name("Import")
		assert(@project.is_member?(@user), "user is member of project")
		assert_response :success
	end

	test "should fail" do
		sign_in @user
		post :create, :file => @file2, :content_type => @content
		assert_redirected_to import_qti_new_path
	end
end
