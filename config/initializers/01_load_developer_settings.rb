# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

dev_settings = {}

if Rails.env == "development" || Rails.env == "test"
  filename = File.join(File.dirname(__FILE__), '..', 'developer_settings.yml')
  if File.file?(filename)
    dev_settings = YAML::load_file(filename)
    dev_settings.symbolize_keys!
  end
end

DEV_SETTINGS = dev_settings