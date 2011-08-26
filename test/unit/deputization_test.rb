# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class DeputizationTest < ActiveSupport::TestCase

  test "basic" do
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory.create(:deputization, :deputizer => nil, :deputy => nil)
    }
    
    u1 = Factory.create(:user)
    u2 = Factory.create(:user)

    assert_raise(ActiveRecord::RecordInvalid) {
      Factory.create(:deputization, :deputizer => u1, :deputy => u1)
    }
    
    dd = Factory.build(:deputization, :deputizer => u1, :deputy => u2)
    
    assert_equal dd.deputizer, u1
    assert_equal dd.deputy, u2
    
    assert_nothing_raised{dd.save!}    
  end
end
