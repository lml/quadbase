Bullring.configure do |config|
  config.execution_timeout_secs = 0.3
  config.server_port = 3033
end

Bullring.logger = Rails.logger