Airbrake.configure do |config|
  config.api_key    = '02c8d0e9da46d826bd5c6f80fc931421'
  config.host       = 'errbit.welaika.com'
  config.port       = 80
  config.secure     = config.port == 443
end
