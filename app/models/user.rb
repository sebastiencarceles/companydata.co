# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

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
  after_update :update_usage_limit!, if: :saved_change_to_plan?

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
end
