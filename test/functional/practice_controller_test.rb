# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class PracticeControllerTest < ActionController::TestCase
  setup do
    ContentParseAndCache.enable_test_parser = true
    @user = FactoryGirl.create(:user)
    @list = Project.default_for_user!(@user)
    @question = FactoryGirl.create(:project_question,
                  :project => @list).question
    @question2 = make_simple_question(:answer_credits => [0, 1],
                                      :method => :create)
    project_question = @question2.project_questions.first
    project_question.project = @list
    project_question.save!
    @published_question = make_simple_question(:method => :create,
                                               :published => true)
    @published_question2 = make_simple_question(:answer_credits => [0, 1],
                                               :method => :create,
                                               :published => true)
  end
  
  # test "should not get show draft not logged in" do
  #   get :show, :question_id => @question.to_param
  #   assert_response 403
  # end
  
  # test "should not get show list not logged in" do
  #   get :show, :project_id => @list.id
  #   assert_response 403
  # end
  
  # test "should not get show draft not authorized" do
  #   user_login
  #   get :show, :question_id => @question.to_param
  #   assert_response 403
  # end
  
  # test "should not get show list not authorized" do
  #   user_login
  #   get :show, :project_id => @list.id
  #   assert_response 403
  # end
  
  # test "should get show draft" do
  #   sign_in @user
  #   get :show, :question_id => @question.to_param
  #   assert_response :success
  # end
  
  # test "should get show published question" do
  #   get :show, :question_id => @published_question.to_param
  #   assert_response :success
  # end
  
  # test "should get show list" do
  #   sign_in @user
  #   get :show, :project_id => @list.id
  #   assert_response :success
  # end
  
  # test "should not get answer_text draft not logged in" do
  #   get :answer_text, :question_id => @question.to_param, :answer_text => 'Something', :answer_confidence => 1
  #   assert_response 403
  # end
  
  # test "should not get answer_text draft not authorized" do
  #   user_login
  #   get :answer_text, :question_id => @question.to_param, :answer_text => 'Something', :answer_confidence => 1
  #   assert_response 403
  # end
  
  # test "should get answer_text draft" do
  #   sign_in @user
  #   get :answer_text, :question_id => @question.to_param, :answer_text => 'Something', :answer_confidence => 1
  #   assert_response :success
  # end
  
  # test "should get answer_text published question" do
  #   get :answer_text, :question_id => @published_question.to_param, :answer_text => 'Something', :answer_confidence => 1
  #   assert_response :success
  # end
  
  #   test "should not get answer_choice draft not logged in" do
  #   get :answer_choices, :question_id => @question2.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 1
  #   assert_response 403
  # end
  
  # test "should not get answer_choices draft not authorized" do
  #   user_login
  #   get :answer_choices, :question_id => @question2.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 1
  #   assert_response 403
  # end
  
  # test "should not get answer_choices draft no answer choices" do
  #   sign_in @user
  #   get :answer_choices, :question_id => @question.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 1
  #   assert_response 403
  # end
  
  # test "should not get answer_choices published question no answer choices" do
  #   get :answer_choices, :question_id => @published_question.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 1
  #   assert_response 403
  # end
  
  # test "should not get answer_choices draft too many choices" do
  #   sign_in @user
  #   get :answer_choices, :question_id => @question2.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 3
  #   assert_response 403
  # end
  
  # test "should not get answer_choices published question too many choices" do
  #   get :answer_choices, :question_id => @published_question2.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 3
  #   assert_response 403
  # end
  
  # test "should get answer_choices draft" do
  #   sign_in @user
  #   get :answer_choices, :question_id => @question2.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 1
  #   assert_response :success
  # end
  
  # test "should get answer_choices published question" do
  #   get :answer_choices, :question_id => @published_question2.to_param, :answer_text => 'Something', :answer_confidence => 1, :answer_choice => 1
  #   assert_response :success
  # end
end
