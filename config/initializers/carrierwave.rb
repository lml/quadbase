if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end