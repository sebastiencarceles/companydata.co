# frozen_string_literal: true

class ApiController < ActionController::API
  before_action :authenticate_from_api_key!
  before_action :check_authentication
  before_action :increment_api_calls

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
      render json: { error: "unauthenticated user" }, status: :unauthorized unless user_signed_in?
    end

    def increment_api_calls
      usage = current_user.usages.find_or_create_by!(year: Date.today.year, month: Date.today.month) do |usage|
        usage.limit = current_user.plan_limit
      end
      count = usage.count + 1
      usage.update_columns(count: count)

      render json: { error: "plan limit reached" }, status: :forbidden unless usage.limit == 0 || count <= usage.limit
    end
end
