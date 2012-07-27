# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ListMemberTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign is_default" do
    wm = ListMember.new(:is_default => true)
    assert !wm.is_default
  end

  test "default for user" do 
    wm1 = FactoryGirl.create(:list_member, :is_default => true)
    wm2 = FactoryGirl.create(:list_member, :user => wm1.user)

    assert_equal wm1, ListMember.default_for_user(wm1.user)
  end

  test "make default" do
    wm1 = FactoryGirl.create(:list_member, :is_default => true)
    wm2 = FactoryGirl.create(:list_member, :user => wm1.user)
    
    assert wm1.is_default, "a"
    assert !wm2.is_default,  "b"
    
    wm2.make_default!
    
    wm1.reload
    wm2.reload
    
    assert !wm1.is_default, "c"
    assert wm2.is_default, "d" 
  end
  
  test "can't have more than 1 default" do 
    wm1 = FactoryGirl.create(:list_member, :is_default => true)
    
    assert_raise(ActiveRecord::RecordInvalid) { 
      FactoryGirl.create(:list_member, :user => wm1.user, :is_default => true)
    }
  end

  test "can't add member twice" do
    user = FactoryGirl.create(:user)
    list = FactoryGirl.create(:list)
    assert_nothing_raised {FactoryGirl.create(:list_member, :list => list, :user => user)}
    assert_raise(ActiveRecord::RecordInvalid) {FactoryGirl.create(:list_member, :list => list, :user => user)}
  end

  test "removing last member destroys list" do
    wm0 = FactoryGirl.create(:list_member)
    w = wm0.list
    wm1 = FactoryGirl.create(:list_member, :list => w)
    wm0.destroy
    assert_nothing_raised { List.find(w.id) }
    wm1.destroy
    assert_raise(ActiveRecord::RecordNotFound) { List.find(w.id) }
  end

end
