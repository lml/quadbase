# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

secret_settings_filename = File.join(File.dirname(__FILE__), '..', 'secret_settings.yml')

SECRET_SETTINGS = File.file?(secret_settings_filename) ?
                  YAML::load_file(secret_settings_filename) : {}

SECRET_SETTINGS.symbolize_keys!
