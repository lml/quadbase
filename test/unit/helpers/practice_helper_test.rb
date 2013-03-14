# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class PracticeHelperTest < ActionView::TestCase
  test 'choice_letter' do
    assert_equal 'a', choice_letter(0)
    assert_equal 'b', choice_letter(1)
    assert_equal 'c', choice_letter(2)
    assert_equal 'd', choice_letter(3)
    assert_equal 'e', choice_letter(4)
  end
end
