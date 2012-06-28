# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase

  setup do
    ContentParseAndCache.enable_test_parser = true
    @user = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @question = FactoryGirl.create(:project_question,
                               :project => Project.default_for_user!(@user)).question
    @question_collaborator = FactoryGirl.create(:question_collaborator,
                                            :question => @question,
                                            :user => @user,
                                            :is_author => true,
                                            :is_copyright_holder => true)
    @question_collaborator1 = FactoryGirl.create(:question_collaborator,
                                            :question => @question,
                                            :user => @user2,
                                            :is_author => true,
                                            :is_copyright_holder => true)
    @question2 = FactoryGirl.create(:project_question,
                              :project => Project.default_for_user!(@user)).question
    @question_collaborator2 = FactoryGirl.create(:question_collaborator,
                                            :question => @question2,
                                            :user => @user,
                                            :is_author => true,
                                            :is_copyright_holder => true)
    @question_collaborator3 = FactoryGirl.create(:question_collaborator,
                                            :question => @question2,
                                            :user => @user2,
                                            :is_author => true,
                                            :is_copyright_holder => true)
    @published_question = make_simple_question(:method => :create,
                                               :published => true)
    ContentParseAndCache.enable_test_parser = false
  end

  def enable_lock
    Question.class_variable_set('@@lock_timeout', 15.minutes)
  end

  def disable_lock
    Question.class_variable_set('@@lock_timeout', 0)
  end

  def with_lock
    # Enables locks for the given block
    # and ensures it is disabled afterwards
    enable_lock
    yield
    ensure
      disable_lock
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get get_started" do
    get :get_started
    assert_response :success
  end
  
  test "should not get new not logged in" do
    get :new
    assert_redirected_to login_path
  end

  test "should get new" do
    user_login
    get :new
    assert_response :success
  end
  
  test "should not create initial question not logged in" do
    post :create_simple
    assert_redirected_to login_path
  end

  test "should create question" do
    sign_in @user
    post :create_simple
    
    question = Question.find(:last)

    assert question.has_role?(@user, :author)
    assert question.has_role?(@user, :copyright_holder)

    assert Project.default_for_user(@user).has_question?(question)

    assert_redirected_to edit_question_path(assigns(:question))
  end

  test "should not show question not logged in" do
    get :show, :id => @question.to_param
    assert_response(403)
  end

  test "should not show question not authorized" do
    user_login
    get :show, :id => @question.to_param
    assert_response(403)
  end

  test "should show question" do
    sign_in @user
    get :show, :id => @question.to_param
    assert_response :success
  end

  test "should show published question" do
    get :show, :id => @published_question.to_param
    assert_response :success
  end

  test "should not get edit not logged in" do
    get :edit, :id => @question.to_param
    assert_redirected_to login_path
  end

  test "should not get edit not authorized" do
    user_login
    get :edit, :id => @question.to_param
    assert_response(403)
  end

  test "should get edit" do
    sign_in @user
    get :edit, :id => @question.to_param
    assert_response :success
  end

  test "should get edit with lock" do
    with_lock do
      sign_in @user
      get :edit, :id => @question.to_param
      assert_response :success
    end
  end

  test "should not get edit locked question" do
    with_lock do
      sign_in @user
      get :edit, :id => @question.to_param
      assert_response :success
      sign_out @user
      sign_in @user2
      get :edit, :id => @question.to_param
      assert_redirected_to question_path(@question)
    end
  end

  test "should not update question not logged in" do
    put :update, :id => @question.to_param, :question => @question.attributes
    assert_redirected_to login_path
  end

  test "should not update question not authorized" do
    user_login
    put :update, :id => @question.to_param, :question => @question.attributes
    assert_response(403)
  end

  test "should update question" do
    sign_in @user
    old_content = @question.content
    attributes = @question.attributes
    new_content = 'New content'
    attributes[:content] = new_content
    assert_not_equal old_content, new_content
    put :update, :id => @question.to_param, :question => attributes
    assert_equal @question.reload.content, new_content
    assert_redirected_to question_path(assigns(:question))
  end

  test "should update question with lock" do
    with_lock do
      sign_in @user
      get :edit, :id => @question.to_param
      assert_response :success
      old_content = @question.content
      attributes = @question.attributes
      new_content = 'New content'
      attributes[:content] = new_content
      assert_not_equal old_content, new_content
      put :update, :id => @question.to_param, :question => attributes
      assert_equal @question.reload.content, new_content
      assert_redirected_to question_path(assigns(:question))
    end
  end

  test "should not update question no lock" do
    with_lock do
      sign_in @user
      old_content = @question.content
      attributes = @question.attributes
      new_content = 'New content'
      attributes[:content] = new_content
      assert_not_equal old_content, new_content
      put :update, :id => @question.to_param, :question => attributes
      assert_equal @question.reload.content, old_content
      assert_redirected_to question_path(assigns(:question))
    end
  end

  test "should not update locked question" do
    with_lock do
      sign_in @user
      get :edit, :id => @question.to_param
      assert_response :success
      sign_out @user
      sign_in @user2
      old_content = @question.content
      attributes = @question.attributes
      new_content = 'New content'
      attributes[:content] = new_content
      assert_not_equal old_content, new_content
      put :update, :id => @question.to_param, :question => attributes
      assert_equal @question.reload.content, old_content
      assert_redirected_to question_path(assigns(:question))
    end
  end

  test "should not destroy question not logged in" do
    assert_difference('Question.count', 0) do
      delete :destroy, :id => @question.to_param
    end
    assert_redirected_to login_path
  end

  test "should not destroy question not authorized" do
    user_login
    assert_difference('Question.count', 0) do
      delete :destroy, :id => @question.to_param
    end
    assert_response(403)
  end

  test "should destroy question" do
    sign_in @user
    assert_difference('Question.count', -1) do
      delete :destroy, :id => @question.to_param
    end
    assert_redirected_to questions_path
  end

  test "should search questions" do
    post :search, :text_query => "Some Query",
                  :selected_type => "All Questions",
                  :selected_where => "All Places"
    assert_response :success
    assert_not_nil assigns(:questions)
  end

  test "should preview_publish question" do
    sign_in @user
    question_ids = [@question.id, @question2.id]
    get :preview_publish, :question_ids => question_ids
    assert_response :success
  end

  test "should publish question" do
    sign_in @user
    assert !@question.is_published?
    assert !@question2.is_published?
    @question.get_lock!(@user)
    @question2.get_lock!(@user)
    question_ids = [@question.id, @question2.id]
    put :publish, :question_ids => question_ids,
                  :agreement_checkbox => "1"
    @question.reload
    @question2.reload
    assert @question.is_published?
    assert @question2.is_published?
    assert_redirected_to questions_path
    assert_not_nil assigns(:questions)
  end

  test "should not get edit_license not logged in" do
    get :edit_license, :question_id => @question.to_param
    assert_redirected_to login_path
  end

  test "should not get edit_license not authorized" do
    user_login
    get :edit_license, :question_id => @question.to_param
    assert_response(403)
  end

  test "should get edit_license" do
    sign_in @user
    get :edit_license, :question_id => @question.to_param
    assert_response :success
  end

  test "should not update_license not logged in" do
    put :update_license, :question_id => @question.to_param,
                         :question => {:license_id => License.default.id}
    assert_redirected_to login_path
  end

  test "should not update_license not authorized" do
    user_login
    put :update_license, :question_id => @question.to_param,
                         :question => {:license_id => License.default.id}
    assert_response(403)
  end

  test "should update_license" do
    sign_in @user
    put :update_license, :question_id => @question.to_param,
                         :question => {:license_id => License.default.id}
    assert_redirected_to question_path(assigns(:question))
  end

end
