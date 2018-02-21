# frozen_string_literal: true

class PaymentController < ApplicationController
  def show
    current_user.update(plan: "unlimited")
    Tracking::Mixpanel&.track(current_user.id, "Visit payment")
  end
end
