# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectQuestionsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @question = FactoryGirl.create(:simple_question)
    @question2 = FactoryGirl.create(:simple_question)
    @project = Project.default_for_user!(@user)
    @project_question = FactoryGirl.create(:project_question, :project => @project, :question => @question)
    @project_question2 = FactoryGirl.create(:project_question, :project => @project, :question => @question2)
    @published_question = make_simple_question(:method => :create, :published => true)
    @published_project_question = FactoryGirl.create(:project_question,
                                                   :question => @published_question)
  end

  test "should not move project_question not logged in" do
    project = FactoryGirl.create(:project, :members => [@user])
    assert @project.has_question?(@question)
    assert !project.has_question?(@question)
    put :move, :project_id => @project.to_param,
               :project_question_ids => [@project_question.to_param],
               :move => [project.to_param]
    assert_redirected_to login_path
    assert @project.has_question?(@question)
    assert !project.has_question?(@question)
  end

  test "should not move project_question not authorized" do
    user_login
    project = FactoryGirl.create(:project, :members => [@user])
    assert @project.has_question?(@question)
    assert !project.has_question?(@question)
    put :move, :project_id => @project.to_param,
               :project_question_ids => [@project_question.to_param],
               :move => [project.to_param]
    assert_response(403)
    assert @project.has_question?(@question)
    assert !project.has_question?(@question)
  end

  test "should move project_question" do
    sign_in @user
    project = FactoryGirl.create(:project, :members => [@user])
    assert @project.has_question?(@question), "a"
    assert !project.has_question?(@question), "b"
    put :move, :project_id => @project.to_param,
               :project_question_ids => [@project_question.to_param],
               :move => [project.to_param]
    assert_redirected_to project_path(@project), "c"
    @project.questions.reload
    assert !@project.has_question?(@question), "d"
    assert project.has_question?(@question), "e"
  end

  test "should not copy project_question not logged in" do
    project = FactoryGirl.create(:project, :members => [@user])
    assert !project.has_question?(@question)
    assert_difference('project.project_questions.count', 0) do
      put :copy, :project_id => @project.to_param,
                 :project_question_ids => [@project_question.to_param],
                 :copy => [project.to_param]
    end
    assert_redirected_to login_path
    assert !project.has_question?(@question)
  end

  test "should not copy project_question not authorized" do
    user_login
    project = FactoryGirl.create(:project, :members => [@user])
    assert !project.has_question?(@question)
    assert_difference('project.project_questions.count', 0) do
      put :copy, :project_id => @project.to_param,
                 :project_question_ids => [@project_question.to_param],
                 :copy => [project.to_param]
    end
    assert_response(403)
    assert !project.has_question?(@question)
  end

  test "should copy project_question" do
    sign_in @user
    project = FactoryGirl.create(:project, :members => [@user])
    assert !project.has_question?(@question)
    assert_difference('project.project_questions.count', 1) do
      put :copy, :project_id => @project.to_param,
                 :project_question_ids => [@project_question.to_param],
                 :copy => [project.to_param]
    end
    assert_redirected_to project_path(@project)
  end

  test "should copy project_question published question" do
    sign_in @user
    assert !@project.has_question?(@published_question)
    assert_difference('@project.project_questions.count', 1) do
      put :copy, :project_id => @published_project_question.project.to_param,
                 :project_question_ids => [@published_project_question.to_param],
                 :copy => [@project.to_param]
    end
    assert @project.project_questions.detect { |wq| wq.question.source_question == @published_question }
    assert_redirected_to project_path(@published_project_question.project)
  end

  test "should preview_publish project_questions" do
    sign_in @user
    question_ids = [@question.id, @question2.id]
    project_question_ids = [@project_question.to_param, @project_question2.to_param]
    put :preview_publish, :project_id => @project.to_param,
                          :project_question_ids => project_question_ids
    assert_response :success
  end

  test "should not destroy project_question not logged in" do
    assert_difference('ProjectQuestion.count', 0) do
      delete :destroy, :project_id => @project.to_param,
                       :project_question_ids => [@project_question.to_param]
    end
    assert_redirected_to login_path
  end

  test "should not destroy project_question not authorized" do
    user_login
    assert_difference('ProjectQuestion.count', 0) do
      delete :destroy, :project_id => @project.to_param,
                       :project_question_ids => [@project_question.to_param]
    end
    assert_response(403)
  end

  test "should destroy project_question" do
    sign_in @user
    assert_difference('ProjectQuestion.count', -1) do
      delete :destroy, :project_id => @project.to_param,
                       :project_question_ids => [@project_question.to_param]
    end
    assert_redirected_to project_path(@project)
  end
end
