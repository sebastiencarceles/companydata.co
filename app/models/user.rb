# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are: :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  
  has_secure_token :api_key
  has_many :usages

  PLANS = {
    free: 100,
    small: 1000,
    medium: 10000,
    unlimited: -1
  }

  validates_inclusion_of :plan, in: PLANS.keys.map(&:to_s)
  
  after_update :update_usage_limit!, if: :saved_change_to_plan?

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    self.find_by_email(email)
  end

  def plan_limit
    PLANS[plan.to_sym]
  end

  private

    def update_usage_limit!
      usage = usages.find_by(year: Date.today.year, month: Date.today.month)
      if usage
        usage.update!(limit: plan_limit)
      else
        usages.create!(year: Date.today.year, month: Date.today.month, limit: plan_limit)
      end
    end
end
