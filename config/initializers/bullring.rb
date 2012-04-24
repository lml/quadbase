Bullring.logger = Rails.logger

Bullring.configure do |config|
  config.execution_timeout_secs = 0.3
  config.server_port = 3033
end

LogicLibraryVersion.all.each do |version|
  # Give Bullring all the library scripts and their names.  A library version's
  # name is its ID
  Bullring.add_library(version.id.to_s, version.code)
end