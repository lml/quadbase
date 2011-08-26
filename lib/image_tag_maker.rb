# Copyright (c) 2011 Rice University.  All rights reserved.

class AttachableImageTagMaker
  def initialize(attachable_id)
    @attachable_id = attachable_id
  end
  
  def make_tag(image_name) 
    "<img src=\"/#{AttachableAsset.get_asset(@attachable_id, image_name).path(:medium)}\">"
  end
end
