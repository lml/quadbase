# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
#require File.expand_path(File.dirname(__FILE__) + "/blueprints")

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  # Add more helper methods to be used by all tests here...

  def assert_equal_string_strip_whitespace(a1, a2)
    assert_equal a1.gsub(/\s+/, ''), a2.gsub(/\s+/, '')
  end
  
end

class ActionController::TestCase

  include Devise::TestHelpers

  def home_path
    root_path
  end

  def login_path
    new_user_session_path
  end

  def admin_login
    admin = FactoryGirl.create(:user, :is_administrator => true)
    sign_in admin
  end

  def user_login
    admin = FactoryGirl.create(:user, :is_administrator => true)
    user = FactoryGirl.create(:user)
    sign_in user
  end

end
