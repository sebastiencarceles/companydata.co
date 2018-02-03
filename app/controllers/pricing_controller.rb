class PricingController < ApplicationController
  def show
  end

  def choose
    plan = pricing_params[:plan]
    if user_signed_in?
      if plan == "free"
        current_user.update(plan: :free)
        flash.notice = "Success! Your plan is now #{plan}"
        redirect_to root_path
      else
        # TODO do not update and redirect to payment
        current_user.update(plan: plan)
        flash.notice = "Congrats! Your plan is now #{plan}"
        redirect_to root_path
      end
    else
      flash.notice = "You will be redirected to the payment after creating an account"
      redirect_to new_user_registration_path(plan: plan)
    end
  end

  private

    def pricing_params
      params.require(:pricing).permit(:plan)
    end
end
