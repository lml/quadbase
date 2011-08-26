# Copyright (c) 2011 Rice University.  All rights reserved.

DEV_SETTINGS = {}

if Rails.env == "development" || Rails.env == "test"
  filename = File.join(File.dirname(__FILE__), '..', 'developer_settings.yml')
  if File.file?(filename)
    DEV_SETTINGS = YAML::load_file(filename)
    DEV_SETTINGS.symbolize_keys!
  end
end