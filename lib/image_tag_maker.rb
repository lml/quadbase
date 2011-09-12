# Copyright (c) 2011 Rice University.  All rights reserved.

class AttachableImageTagMaker
  def initialize(attachable)
    @attachable = attachable
  end
  
  def make_tag(image_name) 
    "<img src=\"/#{@attachable.get_asset(image_name).path(:medium)}\">"
  end
end
