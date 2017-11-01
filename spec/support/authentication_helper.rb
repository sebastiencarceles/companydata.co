module AuthenticationHelper
  def current_user
    @user ||= FactoryGirl.create :user
  end

  def authentication_header
    token = Knock::AuthToken.new(payload: { sub: current_user.id }).token
    {
      'Authorization': "Bearer #{token}"
    }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end