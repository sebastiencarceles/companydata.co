# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates_acceptance_of :terms_of_service

  has_secure_token :api_key
  has_many :counters, dependent: :destroy

  after_create :sign
  after_create :subscribe
  after_create :track_creation
  after_create :track_update

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by_email(email)
  end

  def admin?
    email == "sebastien@companydata.co"
  end

  private

    def sign
      Billing::SignWorker.perform_async(id)
    end

    def subscribe
      Billing::SubscribeWorker.perform_in(1.minute, id)
    end

    def track_creation
      Tracking::TrackWorker.perform_async(id, "Registration")
    end

    def track_update
      Tracking::EmailWorker.perform_async(id, email)
    end
end
