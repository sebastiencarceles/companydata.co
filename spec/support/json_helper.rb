module JsonHelper
  def parsed_body
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonHelper, type: :request
end