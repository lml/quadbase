# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class PracticeControllerTest < ActionController::TestCase
  setup do
    ContentParseAndCache.enable_test_parser = true
    @user = FactoryGirl.create(:user)
    @list = List.default_for_user!(@user)
    @question = FactoryGirl.create(:list_question,
                  :list => @list).question
    @question2 = make_simple_question(:answer_credits => [0, 1],
                                      :method => :create)
    list_question = @question2.list_questions.first
    list_question.list = @list
    list_question.save!
    @published_question = make_simple_question(:method => :create,
                                               :published => true)
    @published_question2 = make_simple_question(:answer_credits => [0, 1],
                                               :method => :create,
                                               :published => true)
  end
  
  test "should not get show draft not logged in" do
    get :show, :ids => @question.to_param
    assert_response 403
  end
  
  test "should not get show list not logged in" do
    get :show, :ids => "L#{@list.id}"
    assert_response 403
  end
  
  test "should not get show draft not authorized" do
    user_login
    get :show, :ids => @question.to_param
    assert_response 403
  end
  
  test "should not get show list not authorized" do
    user_login
    get :show, :ids => "L#{@list.id}"
    assert_response 403
  end
  
  test "should get show draft" do
    sign_in @user
    get :show, :ids => @question.to_param
    assert_response :success
  end
  
  test "should get show published question" do
    get :show, :ids => @published_question.to_param
    assert_response :success
  end
  
  test "should get show list" do
    sign_in @user
    get :show, :ids => "L#{@list.id}"
    assert_response :success
  end
end
