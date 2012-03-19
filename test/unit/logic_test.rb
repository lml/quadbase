require 'test_helper'

class LogicTest < ActiveSupport::TestCase

  test "basic" do
    assert_nothing_raised{Factory.create(:logic)}
  end

  test "reserved words not allowed" do
    assert_raise(ActiveRecord::RecordInvalid) {Factory.create(:logic, :variables => 'x, y, continue')}
  end
  
  test "start with letter or underscore" do
    assert_raise(ActiveRecord::RecordInvalid) {Factory.create(:logic, :variables => '9x')}
  end
  
  test "run" do
    ll = Factory.create(:logic, :code => 'x = 3', :variables => 'x')
    result = ll.run
    assert_equal 3, result.variables["x"]
  end
  
  test 'simple_random' do
    ll = Factory.create(:logic, :code => 'x = Math.random()', :variables => 'x')
    result_s2_1 = ll.run(:seed => 2)
    result_s2_2 = ll.run(:seed => 2)
    result_s3_1 = ll.run(:seed => 3)
    assert_equal result_s2_1.variables["x"], result_s2_2.variables["x"]
    assert_not_equal result_s3_1.variables["x"], result_s2_2.variables["x"]
  end
  
  test 'pass in old outputs' do
    l1 = Factory.create(:logic, :code => 'x = 3', :variables => 'x')
    
    result_l1 = l1.run
    assert_equal 3, result_l1.variables["x"]
    
    l2 = Factory.create(:logic, :code => 'y = 2*x', :variables => 'y')

    result_l2_1 = l2.run(:prior_output => result_l1)
    result_l2_2 = l2.run(:prior_output => result_l1)
    
    assert_equal 6, result_l2_1.variables["y"], "alpha"
    assert_equal 6, result_l2_2.variables["y"], "beta"
  end
end
