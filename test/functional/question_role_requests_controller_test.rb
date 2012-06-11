# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionRoleRequestsControllerTest < ActionController::TestCase
  setup do
    @member = FactoryGirl.create(:user)
    @collaborator = FactoryGirl.create(:user)
    @collaborator_member = FactoryGirl.create(:user)
    wq = FactoryGirl.create(:project_question,
                        :project => Project.default_for_user!(@member))
    w = wq.project
    @question = wq.question
    FactoryGirl.create(:project_member, :project => w, :user => @collaborator_member)
    qc = FactoryGirl.create(:question_collaborator,
                         :user => @collaborator,
                         :question => @question)
    qc2 = FactoryGirl.create(:question_collaborator,
                         :user => @collaborator_member,
                         :question => @question,
                         :is_author => true) #already an author so can auto accept
    @question_role_request = FactoryGirl.build(:question_role_request, :question_collaborator => qc, :requestor => @member, :toggle_is_author => true)
    @question_role_request_auto = FactoryGirl.build(:question_role_request, :question_collaborator => qc2, :requestor => @collaborator_member, :toggle_is_copyright_holder => true)
  end

  test "should not create question_role_request not logged in" do
    assert_difference('QuestionRoleRequest.count', 0) do
      post :create, :question_role_request => @question_role_request.attributes
    end
    assert_redirected_to login_path
  end

  test "should not create question_role_request not authorized" do
    sign_in @collaborator
    assert_difference('QuestionRoleRequest.count', 0) do
      post :create, :question_role_request => @question_role_request.attributes
    end
    assert_response(403)
  end

  test "should create question_role_request" do
    sign_in @member
    assert_difference('QuestionRoleRequest.count') do
      post :create, :question_role_request => @question_role_request.attributes
    end
    assert_redirected_to question_question_collaborators_path(@question)
  end

  test "should autotoggle question_role_request" do
    sign_in @collaborator_member
    assert_difference('QuestionRoleRequest.count', 0) do
      post :create, :question_role_request => @question_role_request_auto.attributes
    end
    assert_redirected_to question_question_collaborators_path(@question)
  end

  test "should not accept question_role_request not logged in" do
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', 0) do
      put :accept, :question_role_request_id => @question_role_request.to_param
    end
    assert_redirected_to login_path
  end

  test "should not accept question_role_request not authorized" do
    sign_in @member
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', 0) do
      put :accept, :question_role_request_id => @question_role_request.to_param
    end
    assert_response(403)
  end

  test "should accept question_role_request" do
    sign_in @collaborator
    @question_role_request.save!
    @question_role_request.approve!
    assert_difference('QuestionRoleRequest.count', -1) do
      put :accept, :question_role_request_id => @question_role_request.to_param
    end
    assert_redirected_to inbox_path
  end

  test "should not reject question_role_request not logged in" do
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', 0) do
      put :reject, :question_role_request_id => @question_role_request.to_param
    end
    assert_redirected_to login_path
  end

  test "should not reject question_role_request not authorized" do
    sign_in @member
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', 0) do
      put :reject, :question_role_request_id => @question_role_request.to_param
    end
    assert_response(403)
  end

  test "should reject question_role_request" do
    sign_in @collaborator
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', -1) do
      put :reject, :question_role_request_id => @question_role_request.to_param
    end
    assert_redirected_to inbox_path
  end

  test "should not destroy question_role_request not logged in" do
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', 0) do
      delete :destroy, :id => @question_role_request.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy question_role_request not authorized" do
    sign_in @collaborator
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', 0) do
      delete :destroy, :id => @question_role_request.to_param
    end
    assert_response(403)
  end

  test "should destroy question_role_request" do
    sign_in @member
    @question_role_request.save!
    assert_difference('QuestionRoleRequest.count', -1) do
      delete :destroy, :id => @question_role_request.to_param
    end
    assert_redirected_to question_question_collaborators_path(@question)
  end

end
