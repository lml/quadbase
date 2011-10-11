# Copyright (c) 2011 Rice University.  All rights reserved.

class AttachableImageTagMaker
  def initialize(attachable)
    @attachable = attachable
  end
  
  def make_tag(image_name) 
    url = Rails.env.production? ? "https" : "http"
    url += "://#{Rails.application.config.default_url_options[:host]}/"
    url += "#{@attachable.get_asset(image_name).path(:medium)}"
    "<img src=\"#{url}\">"
  end
end
