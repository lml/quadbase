# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class AttachableAssetsControllerTest < ActionController::TestCase

  def paramify_values(values)
    # Overloading this method to prevent TestCase from double quoting attachment object during POST
    values
  end

  setup do
    @user = FactoryGirl.create(:user)
    question = FactoryGirl.create(:project_question,
                   :project => Project.default_for_user!(@user)).question
    @attachable_asset = FactoryGirl.build(:attachable_asset, :attachable => question)
    attachment = @attachable_asset.asset.attachment
    fileHash = Hash[ :tempfile => attachment ]
    uploadedFile = ActionDispatch::Http::UploadedFile.new(fileHash)
    uploadedFile.content_type = attachment.content_type
    uploadedFile.original_filename = attachment.original_filename
    uploadedFile.headers = ''
    @attributes = @attachable_asset.attributes.merge({ :asset_attributes => { :attachment => uploadedFile }})
  end

  test "should not create attachable_asset not logged in" do
    assert_difference('AttachableAsset.count', 0) do
      post :create, :attachable_asset => @attributes
    end

    assert_redirected_to login_path
  end

  test "should not create attachable_asset not authorized" do
    user_login
    assert_difference('AttachableAsset.count', 0) do
      post :create, :attachable_asset => @attributes
    end

    assert_response(403)
  end

  test "should create attachable_asset" do
    sign_in @user
    assert_difference('AttachableAsset.count') do
      post :create, :attachable_asset => @attributes
    end

    assert_response :success
  end

  test "should not destroy attachable_asset not logged in" do
    @attachable_asset.save!
    assert_difference('AttachableAsset.count', 0) do
      delete :destroy, :id => @attachable_asset.id
    end

    assert_redirected_to login_path
  end

  test "should not destroy attachable_asset not authorized" do
    @attachable_asset.save!
    user_login
    assert_difference('AttachableAsset.count', 0) do
      delete :destroy, :id => @attachable_asset.id
    end

    assert_response(403)
  end

  test "should destroy attachable_asset" do
    @attachable_asset.save!
    sign_in @user
    assert_difference('AttachableAsset.count', -1) do
      delete :destroy, :id => @attachable_asset.id
    end

    assert_response :redirect
  end

  test "should not download attachable_asset not logged in" do
    @attachable_asset.save!
    get :download, :attachable_asset_id => @attachable_asset.id

    assert_redirected_to login_path
  end

  test "should not download attachable_asset not authorized" do
    @attachable_asset.save!
    user_login
    get :download, :attachable_asset_id => @attachable_asset.id

    assert_response(403)
  end

  test "should download attachable_asset" do
    @attachable_asset.save!
    sign_in @user
    get :download, :attachable_asset_id => @attachable_asset.id

    assert_response :success
  end

end
