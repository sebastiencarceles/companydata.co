# frozen_string_literal: true

class PaymentController < ApplicationController
  def show
    Tracking::Mixpanel&.track(current_user.id, "Visit payment")
  end
end
