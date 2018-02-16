# frozen_string_literal: true

class PricingController < ApplicationController
  def show
  end

  def choose
    plan = pricing_params[:plan]
    if user_signed_in?
      if plan == "free"
        current_user.update(plan: :free)
        flash.notice = t("pricing.choose.success", plan: plan)
        redirect_to root_path
      else
        redirect_to payment_path(plan: plan)
      end
    else
      flash.notice = t("pricing.choose.not_signed_in")
      redirect_to new_user_registration_path(plan: plan)
    end
  end

  private

    def pricing_params
      params.require(:pricing).permit(:plan)
    end
end
