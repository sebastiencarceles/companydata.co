# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_secure_token :api_key
  has_many :usages, -> { order(year: :desc).order(month: :desc) }

  after_create :create_usage!
  after_create :track_creation
  after_update :track_update

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by_email(email)
  end

  private

    def create_usage!
      usages.create!(year: Date.today.year, month: Date.today.month)
    end

    def track_creation
      Tracking::Mixpanel&.track(id, "Registration")
      track_update
    end

    def track_update
      Tracking::Mixpanel&.people&.set(id, 'email': email)
    end
end
