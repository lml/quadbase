# Copyright (c) 2011 Rice University.  All rights reserved.

dev_settings = {}

if Rails.env == "development" || Rails.env == "test"
  filename = File.join(File.dirname(__FILE__), '..', 'developer_settings.yml')
  if File.file?(filename)
    dev_settings = YAML::load_file(filename)
    dev_settings.symbolize_keys!
  end
end

DEV_SETTINGS = dev_settings