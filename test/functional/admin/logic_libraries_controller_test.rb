# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class Admin::LogicLibrariesControllerTest < ActionController::TestCase
  # setup do
  #   @logic_library = logic_libraries(:one)
  # end
  # 
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:logic_libraries)
  # end
  # 
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  # 
  # test "should create logic_library" do
  #   assert_difference('LogicLibrary.count') do
  #     post :create, :logic_library => @logic_library.attributes
  #   end
  # 
  #   assert_redirected_to logic_library_path(assigns(:logic_library))
  # end
  # 
  # test "should show logic_library" do
  #   get :show, :id => @logic_library.to_param
  #   assert_response :success
  # end
  # 
  # test "should get edit" do
  #   get :edit, :id => @logic_library.to_param
  #   assert_response :success
  # end
  # 
  # test "should update logic_library" do
  #   put :update, :id => @logic_library.to_param, :logic_library => @logic_library.attributes
  #   assert_redirected_to logic_library_path(assigns(:logic_library))
  # end
  # 
  # test "should destroy logic_library" do
  #   assert_difference('LogicLibrary.count', -1) do
  #     delete :destroy, :id => @logic_library.to_param
  #   end
  # 
  #   assert_redirected_to logic_libraries_path
  # end
end
