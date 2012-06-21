# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class DigestTest < ActiveSupport::TestCase


  fixtures
  self.use_transactional_fixtures = true

  setup do
    @admin = FactoryGirl.build(:user)
    @admin.is_administrator = true
    @admin.save!
  end

  test "must have user" do
    digest = Digest.new(:subject => "Some Subject")
    assert !digest.save
    digest.user = @admin
    assert digest.save
  end

  test "must have subject" do
    digest = Digest.new
    digest.user = @admin
    assert !digest.save
    digest.subject = "Some Subject"
    assert digest.save
  end
  
  test "must have body" do
  
  end

  test "cannot mass-assign user" do
    digest = Digest.new(:subject => "Some Subject", :user => @admin)
    assert !digest.save
    assert digest.user != @admin
    digest.user = @admin
    assert digest.save
  end
end
