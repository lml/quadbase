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
    assert_equal 3, result["result"]["x"]
  end
  
  test 'simple_random' do
    ll = Factory.create(:logic, :code => 'x = Math.random()', :variables => 'x')
    result_s2_1 = ll.run(2)
    result_s2_2 = ll.run(2)
    result_s3_1 = ll.run(3)
    assert_equal result_s2_1["result"]["x"], result_s2_2["result"]["x"]
    assert_not_equal result_s3_1["result"]["x"], result_s2_2["result"]["x"]
  end
  
  test 'predecessor code' do
    l1 = Factory.create(:logic, :code => 'x = 3', :variables => 'x')
    
    result_l1 = l1.run
    assert_equal 3, result_l1["result"]["x"]
    
    l2 = Factory.create(:logic, :code => 'y = x', :variables => 'y', :predecessor_logic => l1)
    
    result_l2_1 = l2.run
    result_l2_2 = l2.run
    
    assert_equal 3, result_l2_1["result"]["y"]
    assert_equal 3, result_l2_2["result"]["y"]
  end
end
