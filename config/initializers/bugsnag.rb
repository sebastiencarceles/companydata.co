Bugsnag.configure do |config|
  config.api_key = Figaro.env.BUGSNAG_API_KEY
  config.notify_release_stages = ["production"]
end