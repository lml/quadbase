# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class AttachableAssetTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "make_local_name_unique" do
    name = "some_file.name"
    aa0 = FactoryGirl.create(:attachable_asset, :local_name => name)
    assert aa0.local_name == name
    aa1 = FactoryGirl.create(:attachable_asset, :attachable_id => aa0.attachable_id,
                                           :local_name => name)
    assert aa1.local_name != name
  end

  test "destroy_orphan_asset" do
    aa = FactoryGirl.create(:attachable_asset)
    a = aa.asset
    assert Asset.find_by_id(a.id)
    aa.destroy
    assert !Asset.find_by_id(a.id)
  end

  test "can't mass-assign local_name" do
    name = "some_file.name"
    aa = AttachableAsset.new(:local_name => name)
    assert aa.local_name != name
  end

end
