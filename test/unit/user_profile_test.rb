# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class UserProfileTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true

  setup do
    @user_profile = FactoryGirl.create(:user_profile)
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
