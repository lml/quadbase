# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

Bullring.logger = Rails.logger

Bullring.configure do |config|
  config.execution_timeout_secs = 0.3
  config.first_server_port = 3033
  config.jvm_init_heap_size = '80m'
  config.jvm_max_heap_size = '80m'
  config.jvm_young_heap_size = '40m'
  config.server_max_bringup_time = 40
end

# Give Bullring all the library scripts, don't do this until the migration
# actually sets up the table!
if ActiveRecord::Base.connection.tables.include?("logic_library_versions")
  LogicLibraryVersion.all.each do |version|
    version.send_to_bullring
  end
end