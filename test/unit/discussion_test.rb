# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  
  setup do
    @user = Factory.create(:user)
    @user2 = Factory.create(:user)
    
    @discussion = Factory.create(:discussion)
    @comment_thread = @discussion.comment_thread
    @comment_thread.subscribe!(@user)

  end
  
  test "gets user's subsciptions" do
    discussions = Discussion.discussions_for(@user)
    assert discussions.count == 1
    assert discussions.last == @discussion
  end
  
  test "gets subject" do
    assert @discussion.subject != nil
  end
  
end
