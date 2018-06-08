# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates_acceptance_of :terms_of_service

  has_secure_token :api_key
  has_many :usages, -> { order(year: :desc).order(month: :desc) }

  after_create :create_usage!
  after_create :track_creation
  after_create :track_update
  after_update :track_update, if: :saved_change_to_email?

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by_email(email)
  end

  def admin?
    email == "sebastien@companydata.co"
  end

  private

    def create_usage!
      usages.create!(year: Date.today.year, month: Date.today.month)
    end

    def track_creation
      Tracking::TrackWorker.perform_async(id, "Registration")
    end

    def track_update
      Tracking::EmailWorker.perform_async(id, email)
    end
end
