# frozen_string_literal: true

module AuthenticationHelper
  def current_user
    @user ||= create :user
  end

  def current_admin
    @admin ||= create :user, email: "sebastien@companydata.co"
  end

  def authentication_header
    {
      HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(current_user.api_key, "")
    }
  end

  def admin_authentication_header
    {
      HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(current_admin.api_key, "")
    }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
