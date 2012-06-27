# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class LicenseTest < ActiveSupport::TestCase

  fixtures

  test "destroyable?" do
    lic = licenses(:cc_by_3_0)
    assert lic.destroy
    lic = FactoryGirl.create(:license)
    assert FactoryGirl.create(:simple_question, :license => lic)
    lic.reload
    assert !lic.destroy
  end

  test "changeable?" do
    lic = licenses(:cc_by_3_0)
    lic.short_name = "Some Name"
    lic.save!
    assert FactoryGirl.create(:simple_question, :license => lic)
    lic.reload
    lic.agreement_partial_name = "some_partial"
    assert lic.save
    lic.short_name = "Another Name"
    assert !lic.save
  end

  test "only allow one license" do
    lic0 = licenses(:cc_by_3_0)
    lic1 = FactoryGirl.build(:license)
    assert !lic1.save
  end

  test "must have short_name, long_name and url" do
    lic = licenses(:cc_by_3_0)
    lic.reload
    lic.short_name = ""
    assert !lic.save
    lic.reload
    lic.long_name = ""
    assert !lic.save
    lic.reload
    lic.url = ""
    assert !lic.save
    lic.reload
    assert lic.save
  end

  test "can't mass-assign is_default" do
    lic = License.new(:is_default => true)
    assert lic.is_default.nil?
  end

end
