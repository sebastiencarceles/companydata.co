# frozen_string_literal: true

class ApiController < ActionController::API
  before_action :authenticate_from_api_key!
  before_action :check_authentication

  private

    def authenticate_from_api_key!
      auth = request.headers[:HTTP_AUTHORIZATION]
      return if auth.blank?

      encoded = auth.gsub("Basic ", "")
      return if encoded.blank?

      plain = Base64.decode64(encoded)
      email = plain.split(":").first
      api_key = plain.split(":").last

      user = User.where(email: email, api_key: api_key).first
      sign_in(user) if user
    end

    def check_authentication
      render json: { error: "unauthenticated or unauthorized user" }, status: :unauthorized unless user_signed_in?
    end
end
