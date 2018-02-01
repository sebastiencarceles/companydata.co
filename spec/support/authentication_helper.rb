# frozen_string_literal: true

module AuthenticationHelper
  def current_user
    @user ||= FactoryGirl.create :user
  end

  def authentication_header
    {
      HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(current_user.email, current_user.api_key)
    }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
