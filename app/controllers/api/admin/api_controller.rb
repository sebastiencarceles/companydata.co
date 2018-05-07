# frozen_string_literal: true

class Api::Admin::ApiController < ActionController::API
  before_action :authenticate_froom_api_key!
  before_action :check_authentication

  private

    def authenticate_froom_api_key!
      auth = request.headers[:HTTP_AUTHORIZATION]
      return if auth.blank?

      encoded = auth.gsub("Basic ", "")
      return if encoded.blank?

      plain = Base64.decode64(encoded)
      api_key = plain.split(":").first

      user = User.where(api_key: api_key, email: "sebastien@companydata.co").first
      sign_in(user) if user
    end

    def check_authentication
      render json: { error: "unauthenticated user" }, status: :unauthorized unless user_signed_in?
    end
end
