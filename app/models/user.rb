# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_secure_token :api_key
  has_many :usages, -> { order(year: :desc).order(month: :desc) }

  PLANS = {
    free: 100,
    normal: 1000,
    huge: 10000,
    unlimited: 0
  }

  validates_inclusion_of :plan, in: PLANS.keys.map(&:to_s)

  after_create :create_usage!
  after_create :track_creation
  after_update :update_usage_limit!, if: :saved_change_to_plan?
  after_update :track_update

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by_email(email)
  end

  def plan_limit
    PLANS[plan.to_sym]
  end

  private

    def create_usage!
      usages.create!(year: Date.today.year, month: Date.today.month, limit: plan_limit)
    end

    def update_usage_limit!
      usage = usages.find_by(year: Date.today.year, month: Date.today.month)
      if usage
        usage.update!(limit: plan_limit)
      else
        create_usage!
      end
    end

    def track_creation
      Tracking::Mixpanel.track(id, "Registration")
      track_update
    end

    def track_update
      Tracking::Mixpanel.people.set(id, 'email': email, 'plan': plan)
    end
end
