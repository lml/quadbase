# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class HelpController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter {select_tab(:help)}
  
  before_filter :include_mathjax, :only => [:index, :show, :edit]
  before_filter :include_jquery
  
  # This class variable maps topic names to partial names.  This is mostly
  # useful when the topic name does not match the partial name.  If 
  # your topic name is not in this hash, the site will use the topic name
  # as the partial name
  @@topic_partial_names = {
    # "some topic name here" => "corresponding partial name here",
  }
  
  def index
  end
  
  def faq
  end
  
  def contact
  end

  def beta
  end

  def authoring
  end

  def image_help
  end
  
  def about
  end
  
  def legal
  end
  
  def roles
  end
  
  def topic
    @partial_name = @@topic_partial_names[params[:topic_name]]
    @partial_name = params[:topic_name] if @partial_name.nil?
    @options = params[:options] || {}
        
    respond_to do |format|
      format.html
      format.js
    end
end

  def comments
  end
  
  def dialog
    @partial_name = params[:partial_name]
    comments
  end
  
  def messages
  end
end
