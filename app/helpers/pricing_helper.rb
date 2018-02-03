# frozen_string_literal: true

module PricingHelper
  def plan_higher?(plan_a, plan_b)
    User::PLANS.keys.index(plan_a.to_sym) > User::PLANS.keys.index(plan_b.to_sym)
  end

  def plan_lower?(plan_a, plan_b)
    User::PLANS.keys.index(plan_a.to_sym) < User::PLANS.keys.index(plan_b.to_sym)
  end
end
