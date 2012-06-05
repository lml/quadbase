# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  
  test "destroy kills dependent assocs" do
    ww = make_project(:num_questions => 3, :num_members => 1, :method => :create)
    
    ww.destroy
    
    [0,1,2].each do |n|
      assert_raise(ActiveRecord::RecordNotFound) {ProjectQuestion.find(ww.project_questions[n].id)}
      assert_raise(ActiveRecord::RecordNotFound) { Question.find(ww.project_questions[n].question.id) }
    end
    
    assert ww.questions.empty?
    
    assert_raise(ActiveRecord::RecordNotFound) {ProjectMember.find(ww.project_members.first.id)}
    assert_nothing_raised(ActiveRecord::RecordNotFound) { User.find(ww.project_members.first.user.id) }
    
    assert ww.members.empty?
  end
  
  test "default for user" do
    ww = make_project(:num_questions => 3, :num_members => 1, :method => :create)
    ws = Factory.create(:project)
    wm = Factory.create(:project_member, :user => ww.members.first, :project => ws)
    
    assert_not_equal ww, Project.default_for_user(ww.members.first)
    wm.make_default!
    assert_equal ws, Project.default_for_user(ww.members.first)
  end
  
  test "default for user new user" do 
    orig_num_projects = Project.count
    
    new_user = Factory.create(:user)
    
    new_user_default_ws = Project.default_for_user!(new_user)
    
    assert_not_nil new_user_default_ws
    assert_equal orig_num_projects+1, Project.count
  end
  
  test "add question" do
    ww = make_project(:num_questions => 3, :num_members => 1, :method => :create)
    sq = make_simple_question()
    assert_equal ww.questions.length, 3
    assert_raise(ActiveRecord::RecordNotFound) {ProjectQuestion.find(sq.id)}
    ww.add_question!(sq)
    ww.save!
    assert_equal sq.id, ProjectQuestion.find_by_question_id(sq.id).question_id
  end
  
  test "add member" do
    ww = make_project(:num_questions => 3, :num_members => 1, :method => :create)
    user = Factory.create(:user)
    assert_equal ww.members.length, 1
    assert_raise(ActiveRecord::RecordNotFound) {ProjectMember.find(user.id)}
    ww.add_member!(user)
    ww.save!
    assert_equal user, ProjectMember.find_by_user_id(user.id).user
  end

  test "all for user" do
    ww0 = make_project(:num_questions => 3, :num_members => 1, :method => :create)
    ww1 = make_project(:num_questions => 4, :num_members => 2, :method => :create)
    ww2 = make_project(:num_questions => 5, :num_members => 3, :method => :create)
    user = Factory.create(:user)
    assert_equal Project.all_for_user(user).length, 1
    ww0.add_member!(user)
    ww0.save!
    assert_equal Project.all_for_user(user).length, 2
    assert_equal Project.all_for_user(user).second, ww0
    ww1.add_member!(user)
    ww1.save!
    ww2.add_member!(user)
    ww2.save!
    assert_equal Project.all_for_user(user).length, 4
    assert Project.all_for_user(user).include?(ww0)
    assert Project.all_for_user(user).include?(ww1)
    assert Project.all_for_user(user).include?(ww2)
  end

  test "is default for user?" do
    ww0 = make_project(:num_questions => 3, :num_members => 1, :method => :create)
    user = Factory.create(:user)
    assert !ww0.is_default_for_user?(user)
    assert Project.default_for_user(user).nil?
    ww1 = Project.default_for_user!(user)
    assert_equal ww1, Project.default_for_user(user)
    assert ww1.is_default_for_user?(user)
  end

end
