# frozen_string_literal: true

class ApiController < ActionController::API
  before_action :authenticate_from_api_key!
  before_action :check_authentication
  after_action :increment_api_calls

  private

    def authenticate_from_api_key!
      auth = request.headers[:HTTP_AUTHORIZATION]
      return if auth.blank?

      encoded = auth.gsub("Basic ", "")
      return if encoded.blank?

      plain = Base64.decode64(encoded)
      api_key = plain.split(":").first

      user = User.find_by_api_key(api_key)
      sign_in(user) if user
    end

    def check_authentication
      render json: { error: "unauthenticated user" }, status: :unauthorized unless user_signed_in?
    end

    def increment_api_calls
      usage = current_user.usages.find_or_create_by!(year: Date.today.year, month: Date.today.month)
      if current_user.free_calls_count <= 0
        count = usage.count + 1
        usage.update_columns(count: count)
        Tracking::Mixpanel&.people&.increment(current_user.id, "Paids calls": 1)
      else
        current_user.update_columns(free_calls_count: (current_user.free_calls_count - 1))
        Tracking::Mixpanel&.people&.increment(current_user.id, "Free calls": 1)
      end
      Tracking::Mixpanel&.track(current_user.id, "Authenticated API call")
    end
end
