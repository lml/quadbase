# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class QuestionCollaboratorsControllerTest < ActionController::TestCase
  setup do
    @user = Factory.create(:user)
    @question = Factory.create(:project_question,
                               :project => Project.default_for_user!(@user)).question
    @published_question = Factory.create(:project_question,
                                         :project => Project.default_for_user!(@user)).question
    @question_collaborator = Factory.create(:question_collaborator, :question => @question, :is_author => true)
    @published_question_collaborator = Factory.create(:question_collaborator, :question => @published_question, :is_copyright_holder => true)
    @published_question.version = @published_question.next_available_version
    @published_question.save!
  end

  test "should not get index not logged in" do
    get :index, :question_id => @question.to_param
    assert_redirected_to login_path
  end

  test "should not get index not authorized" do
    user_login
    get :index, :question_id => @question.to_param
    assert_response(403)
  end

  test "should get index" do
    sign_in @user
    get :index, :question_id => @question.to_param
    assert_response :success
    assert_not_nil assigns(:question_collaborators)
  end

  test "should not create question_collaborator not logged in" do
    new_collaborator = Factory.build(:question_collaborator, :question => @question)
    assert_difference('QuestionCollaborator.count', 0) do
      post :create, :question_id => @question.to_param, :question_collaborator => new_collaborator.attributes, :username => new_collaborator.user.username
    end
    assert_redirected_to login_path
  end

  test "should not create question_collaborator not authorized" do
    user_login
    new_collaborator = Factory.build(:question_collaborator, :question => @question)
    assert_difference('QuestionCollaborator.count', 0) do
      post :create, 
           :question_id => @question.to_param, 
           :question_collaborator => {:username => Factory.create(:user).username}
    end
    assert_response(403)
  end

  test "should not create question_collaborator published question" do
    sign_in @user
    new_collaborator = Factory.build(:question_collaborator, :question => @published_question)
    assert_difference('QuestionCollaborator.count', 0) do
      post :create, 
           :question_id => @published_question.to_param, 
           :question_collaborator => {:username => @user.username}
    end
    assert_response(403)
  end

  test "should create question_collaborator" do
    sign_in @user
    assert_difference('QuestionCollaborator.count') do
      post :create, 
           :question_id => @question.to_param, 
           :question_collaborator => {:username => @user.username}
    end
    assert_redirected_to question_question_collaborators_path(@question)
  end

  test "should not destroy question_collaborator not logged in" do
    @question_collaborator.is_author = false
    @question_collaborator.save!
    assert_difference('QuestionCollaborator.count', 0) do
      delete :destroy, :question_id => @question.to_param,
                       :id => @question_collaborator.id
    end
    assert_redirected_to login_path
  end

  test "should not destroy question_collaborator not authorized" do
    user_login
    @question_collaborator.is_author = false
    @question_collaborator.save!
    assert_difference('QuestionCollaborator.count', 0) do
      delete :destroy, :question_id => @question.to_param,
                       :id => @question_collaborator.id
    end
    assert_response(403)
  end

  test "should not destroy question_collaborator published question" do
    sign_in @user
    assert_difference('QuestionCollaborator.count', 0) do
      delete :destroy, :question_id => @published_question.to_param,
                       :id => @question_collaborator.id
    end
    assert_redirected_to question_question_collaborators_path(@published_question)
  end

  test "should not destroy question_collaborator with roles" do
    sign_in @user
    assert_difference('QuestionCollaborator.count', 0) do
      delete :destroy, :question_id => @question.to_param,
                       :id => @question_collaborator.id
    end
    assert_redirected_to question_question_collaborators_path(@question)
  end

  test "should destroy question_collaborator" do
    sign_in @user
    @question_collaborator.is_author = false
    @question_collaborator.save!
    assert_difference('QuestionCollaborator.count', -1) do
      delete :destroy, :question_id => @question.to_param,
                       :id => @question_collaborator.id
    end
    assert_redirected_to question_question_collaborators_path(@question)
  end

  test "should not sort question_collaborator not logged in" do
    post :sort, :question_id => @question.to_param, :collaborator => [@question_collaborator]
    assert_redirected_to login_path
  end

  test "should not sort question_collaborator not authorized" do
    user_login
    post :sort, :question_id => @question.to_param, :collaborator => [@question_collaborator]
    assert_response(403)
  end

  test "should not sort question_collaborator published question" do
    sign_in @user
    post :sort, :question_id => @published_question.to_param, :collaborator => [@published_question_collaborator]
    assert_response(403)
  end

  test "should sort question_collaborator" do
    sign_in @user
    post :sort, :question_id => @question.to_param, :collaborator => [@question_collaborator]
    assert_response :success
  end

end
