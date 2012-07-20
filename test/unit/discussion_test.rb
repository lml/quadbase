# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase

  test "cannot mass-assign comment_thread, subject, body" do
    ct = FactoryGirl.create(:comment_thread)
    d = Discussion.new(:comment_thread => ct, :subject => 'head', :body => 'bod')
    assert d.comment_thread != ct
    assert d.subject != 'head'
    assert d.body != 'bod'
  end
  
  test "should have a recipient when subscribed" do
    discussion = FactoryGirl.create(:discussion)
    user = FactoryGirl.create(:user)
    discussion.comment_thread.subscribe!(user)
    assert discussion.has_recipient?(user)
  end
  
  test "should delete discussion when no recipients are left" do
    discussion = FactoryGirl.create(:discussion)
    user = FactoryGirl.create(:user)
    ct = discussion.comment_thread
    ct.subscribe!(user)
    assert discussion.has_recipient?(user)
    
    ct.unsubscribe!(user)
    assert_raise(ActiveRecord::RecordNotFound) { Discussion.find(discussion.id) }
  end
  
end
