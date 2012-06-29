# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# Load the rails application
require File.expand_path('../application', __FILE__)

require 'extensions'
require 'uri_validator'
require 'quadbase_markup'
require 'content_parse_and_cache'
require 'image_tag_maker'
require 'asset_methods'
require 'vote_methods'
require 'form_builder_extensions'
require 'acts_as_numberable'
require 'variated_content_html'

ActionMailer::Base.delivery_method = :sendmail

# Initialize the rails application
Quadbase::Application.initialize!
