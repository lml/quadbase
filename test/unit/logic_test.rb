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
end
