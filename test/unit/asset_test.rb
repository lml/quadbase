# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class AssetTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "must have attachment_file_name" do
    asset = Asset.new
    asset.attachment_content_type = "image/png"
    assert !asset.save
    asset.attachment_file_name = "Some name"
    asset.save!
  end

  test "content_type_allowed" do
    asset = Asset.new
    asset.attachment_file_name = "Some name"
    asset.attachment_content_type = "application/octet-stream"
    assert !asset.save
    asset.attachment_content_type = "image/png"
    asset.save!
  end

  test "cannot mass-assign attachment_file_name, attachment_content_type,
          attachment_file_size, attachment_updated_at, uploader_id" do
    name = "Some name"
    type = "image/png"
    size = 1024
    time = Time.now
    user_id = FactoryGirl.create(:user).id
    asset = Asset.new(:attachment_file_name => name,
                      :attachment_content_type => type,
                      :attachment_file_size => size,
                      :attachment_updated_at => time,
                      :uploader_id => user_id)
    assert !asset.save
    assert asset.attachment_file_name != name
    assert asset.attachment_content_type != type
    assert asset.attachment_file_size != size
    assert asset.attachment_updated_at != time
    assert asset.uploader_id != user_id
  end

end
