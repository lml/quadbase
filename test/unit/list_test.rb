# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ListTest < ActiveSupport::TestCase
  
  test "destroy kills dependent assocs" do
    p = make_list(:num_questions => 3, :num_members => 1, :method => :create)

    pq_ids = p.list_questions.collect{ |pq| pq.id }
    q_ids = p.list_questions.collect{ |pq| pq.question.id }
    pm_ids = p.list_members.collect{ |pm| pm.id }
    u_ids = p.list_members.collect{ |pm| pm.user.id }
    
    p.destroy
    
    pq_ids.each do |pq_id|
      assert_raise(ActiveRecord::RecordNotFound) {ListQuestion.find(pq_id)}
    end

    q_ids.each do |q_id|
      assert_raise(ActiveRecord::RecordNotFound) { Question.find(q_id) }
    end

    pm_ids.each do |pm_id|
      assert_raise(ActiveRecord::RecordNotFound) { ListMember.find(pm_id) }
    end

    u_ids.each do |u_id|
      assert_nothing_raised { User.find(u_id) }
    end
  end
  
  test "default for user" do
    ww = make_list(:num_questions => 3, :num_members => 1, :method => :create)
    ws = FactoryGirl.create(:list)
    wm = FactoryGirl.create(:list_member, :user => ww.members.first, :list => ws)
    
    assert_not_equal ww, List.default_for_user(ww.members.first)
    wm.make_default!
    assert_equal ws, List.default_for_user(ww.members.first)
  end
  
  test "default for user new user" do 
    orig_num_lists = List.count
    
    new_user = FactoryGirl.create(:user)
    
    new_user_default_ws = List.default_for_user!(new_user)
    
    assert_not_nil new_user_default_ws
    assert_equal orig_num_lists+1, List.count
  end
  
  test "add question" do
    ww = make_list(:num_questions => 3, :num_members => 1, :method => :create)
    sq = make_simple_question()
    assert_equal ww.questions.length, 3
    assert_raise(ActiveRecord::RecordNotFound) {ListQuestion.find(sq.id)}
    ww.add_question!(sq)
    ww.save!
    assert_equal sq.id, ListQuestion.find_by_question_id(sq.id).question_id
  end
  
  test "add member" do
    ww = make_list(:num_questions => 3, :num_members => 1, :method => :create)
    user = FactoryGirl.create(:user)
    assert_equal ww.members.length, 1
    assert_raise(ActiveRecord::RecordNotFound) {ListMember.find(user.id)}
    ww.add_member!(user)
    ww.save!
    assert_equal user, ListMember.find_by_user_id(user.id).user
  end

  test "all for user" do
    ww0 = make_list(:num_questions => 3, :num_members => 1, :method => :create)
    ww1 = make_list(:num_questions => 4, :num_members => 2, :method => :create)
    ww2 = make_list(:num_questions => 5, :num_members => 3, :method => :create)
    user = FactoryGirl.create(:user)
    assert List.all_for_user(user).empty?
    ww0.add_member!(user)
    ww0.save!
    assert_equal List.all_for_user(user).length, 1
    assert_equal List.all_for_user(user).first, ww0
    ww1.add_member!(user)
    ww1.save!
    ww2.add_member!(user)
    ww2.save!
    assert_equal List.all_for_user(user).length, 3
    assert List.all_for_user(user).include?(ww0)
    assert List.all_for_user(user).include?(ww1)
    assert List.all_for_user(user).include?(ww2)
  end

  test "is default for user?" do
    ww0 = make_list(:num_questions => 3, :num_members => 1, :method => :create)
    user = FactoryGirl.create(:user)
    assert !ww0.is_default_for_user?(user)
    assert List.default_for_user(user).nil?
    ww1 = List.default_for_user!(user)
    assert_equal ww1, List.default_for_user(user)
    assert ww1.is_default_for_user?(user)
  end

end
