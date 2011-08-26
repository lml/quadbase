# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class UserProfileTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true

  setup do
    @user_profile = Factory.create(:user_profile)
    @user = @user_profile.user
    @user.user_profile = @user_profile
    @user.save!
  end

  # Right now you CAN mass-assign users. Since we never update the profile directly (we always do it nested in user updates), this seems to be fine.

  #test "can't mass-assign user" do
  #  @user.user_profile.destroy
  #  user_profile = UserProfile.new(:user => @user)
  #  assert user_profile.user != @user
  #end

end
