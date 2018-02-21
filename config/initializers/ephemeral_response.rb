EphemeralResponse.configure do |config|
  config.skip_expiration = true
  config.white_list = 'localhost'
end