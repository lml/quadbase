# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class AttachableImageTagMaker
  def initialize(attachable)
    @attachable = attachable
  end
  
  def make_tag(image_name) 
    url = Rails.env.production? ? "https" : "http"
    url += "://#{Rails.application.config.default_url_options[:host]}/"
    asset_got = @attachable.get_asset(image_name)
    if !asset_got.nil?
      url += asset_got.path(:medium)
      "<img src=\"#{url}\">"
    else
      "<span class = 'undefined_variable' title='No image with this name could be found!'>#{image_name}</span>"
    end   
  end
end
