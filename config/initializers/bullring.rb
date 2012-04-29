Bullring.logger = Rails.logger

Bullring.configure do |config|
  config.execution_timeout_secs = 0.3
  config.server_port = 3033
end

# Give Bullring all the library scripts
LogicLibraryVersion.all.each do |version|
  version.send_to_bullring
end