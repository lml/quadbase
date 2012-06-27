# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true

  test "cannot mass-assign encrypted_password, reset_password_token, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, failed_attempts, unlock_token, locked_at, confirmation_token, confirmed_at, confirmation_sent_at, is_administrator, disabled_at" do
    encrypted_password = "somepassword"
    reset_password_token = "sometoken"
    remember_created_at = Time.now
    sign_in_count = 10
    current_sign_in_at = Time.now
    last_sign_in_at = Time.now
    current_sign_in_ip = "127.0.0.1"
    last_sign_in_ip = "127.0.0.1"
    failed_attempts = 1
    unlock_token = "unlockme"
    locked_at = Time.now
    confirmation_token = "confirmme"
    confirmed_at = Time.now
    confirmation_sent_at = Time.now
    is_administrator = true
    disabled_at = Time.now
    u = User.new(:encrypted_password => encrypted_password,
                 :reset_password_token => reset_password_token,
                 :remember_created_at => remember_created_at,
                 :sign_in_count => sign_in_count,
                 :current_sign_in_at => current_sign_in_at,
                 :last_sign_in_at => last_sign_in_at,
                 :current_sign_in_ip => current_sign_in_ip,
                 :last_sign_in_ip => last_sign_in_ip,
                 :failed_attempts => failed_attempts,
                 :unlock_token => unlock_token,
                 :locked_at => locked_at,
                 :confirmation_token => confirmation_token,
                 :confirmed_at => confirmed_at,
                 :confirmation_sent_at => confirmation_sent_at,
                 :is_administrator => is_administrator,
                 :disabled_at => disabled_at)
    assert u.encrypted_password != encrypted_password
    assert u.reset_password_token != reset_password_token
    assert u.remember_created_at != remember_created_at
    assert u.sign_in_count != sign_in_count
    assert u.current_sign_in_at != current_sign_in_at
    assert u.last_sign_in_at != last_sign_in_at
    assert u.current_sign_in_ip != current_sign_in_ip
    assert u.last_sign_in_ip != last_sign_in_ip
    assert u.failed_attempts != failed_attempts
    assert u.unlock_token != unlock_token
    assert u.locked_at != locked_at
    assert u.confirmation_token != confirmation_token
    assert u.confirmed_at != confirmed_at
    assert u.confirmation_sent_at != confirmation_sent_at
    assert u.is_administrator != is_administrator
    assert u.disabled_at != disabled_at
  end
  
  test "username cannot be changed" do
    user = FactoryGirl.create(:user)
    assert user.save
    user.username = "NewName"
    assert !user.save
  end
  
  test "cannot have two usernames only differ by case" do
    user0 = FactoryGirl.build(:user)
    user1 = FactoryGirl.build(:user, :username => user0.username.swapcase)
    assert_not_equal user0.username, user1.username
    assert user0.save
    assert !user1.save
  end

  test "disable user" do
    user = FactoryGirl.create(:user)
    assert !user.is_disabled?
    user.disable!
    assert user.is_disabled?
  end

  test "at least one admin" do
    admin0 = FactoryGirl.create(:user, :is_administrator => true)
    admin0.is_administrator = false
    assert !admin0.save
    assert !admin0.disable!
    admin1 = FactoryGirl.create(:user, :is_administrator => true)
    assert admin0.save
    assert admin0.disable!
  end

  test "search" do
    user0 = FactoryGirl.create(:user, :first_name => "Some", :last_name => "User", :username => "SomeUser0", :email => "su0@example.com")
    user1 = FactoryGirl.create(:user, :first_name => "Another", :last_name => "User", :username => "AnotherUser1", :email => "au1@example.com")
    user2 = FactoryGirl.create(:user, :first_name => "John", :last_name => "Doe", :username => "JohnDoe2000", :email => "jd2000@example.com")
    user3 = FactoryGirl.create(:user, :first_name => "Jane", :last_name => "Doe", :username => "JaneDoe3000", :email => "jd3000@example.com")

    search0 = User.search('All', '')
    search1 = User.search('All', 'Some')
    search2 = User.search('All', 'er')
    search3 = User.search('Name', 'User')
    search4 = User.search('Username', 'User')
    search5 = User.search('Username', 'Another')
    search6 = User.search('Email', 'example.com')
    search7 = User.search('Email', 'jd')
    search8 = User.search('All', 'Doe')

    assert !search0.include?(user0)
    assert !search0.include?(user1)
    assert !search0.include?(user2)
    assert !search0.include?(user3)

    assert search1.include?(user0)
    assert !search1.include?(user1)
    assert !search1.include?(user2)
    assert !search1.include?(user3)

    assert !search2.include?(user0)
    assert !search2.include?(user1)
    assert !search2.include?(user2)
    assert !search2.include?(user3)

    assert search3.include?(user0)
    assert search3.include?(user1)
    assert !search3.include?(user2)
    assert !search3.include?(user3)

    assert !search4.include?(user0)
    assert !search4.include?(user1)
    assert !search4.include?(user2)
    assert !search4.include?(user3)

    assert !search5.include?(user0)
    assert search5.include?(user1)
    assert !search5.include?(user2)
    assert !search5.include?(user3)

    assert !search6.include?(user0)
    assert !search6.include?(user1)
    assert !search6.include?(user2)
    assert !search6.include?(user3)

    assert !search7.include?(user0)
    assert !search7.include?(user1)
    assert search7.include?(user2)
    assert search7.include?(user3)

    assert !search8.include?(user0)
    assert !search8.include?(user1)
    assert search8.include?(user2)
    assert search8.include?(user3)
  end
  
  test "deputies" do
    u1 = FactoryGirl.create(:user)
    u2 = FactoryGirl.create(:user)

    dd = FactoryGirl.create(:deputization, :deputizer => u1, :deputy => u2)

    assert_equal u1.owned_deputizations.size, 1
    assert_equal u1.deputies.size, 1
    assert_equal u1.deputies.first, u2
    
    assert_equal u2.received_deputizations.size, 1
    assert_equal u2.deputizers.size, 1
    assert_equal u2.deputizers.first, u1
  end

end
