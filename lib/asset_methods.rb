# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module AssetMethods
  
  def get_image_tag_maker
    AttachableImageTagMaker.new(respond_to?(:get_attachable) ? get_attachable : self)
  end
  
  def get_asset(local_name)
    attachable_assets.select{|aa| aa.local_name == local_name}.first.try(:asset)
  end
  
end
