# frozen_string_literal: true

class PaymentController < ApplicationController
  def show
    current_user.update(plan: "unlimited") if user_signed_in?
    # TODO add link to API documentation
  end
end
