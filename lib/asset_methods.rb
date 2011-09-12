# Copyright (c) 2011 Rice University.  All rights reserved.

module AssetMethods
  
  def get_image_tag_maker
    AttachableImageTagMaker.new(respond_to?(:get_attachable) ? get_attachable : self)
  end
  
  def get_asset(local_name)
    attachable_assets.select{|aa| aa.local_name == local_name}.first.asset
  end
  
end