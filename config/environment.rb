# Copyright (c) 2011 Rice University.  All rights reserved.

# Load the rails application
require File.expand_path('../application', __FILE__)

require 'extensions'
require 'uri_validator'
require 'quadbase_markup'
require 'content_parse_and_cache'
require 'image_tag_maker'
require 'asset_methods'
require 'vote_methods'

ActionMailer::Base.delivery_method = :sendmail

# Initialize the rails application
Quadbase::Application.initialize!
