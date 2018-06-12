# frozen_string_literal: true

class UsersController < ApplicationController
  def renew
    if user_signed_in?
      current_user.regenerate_api_key
      redirect_to edit_user_registration_path
    else
      redirect_to root_path
    end
  end

  def customer_portal
    @customer_portal = Proabono.new(current_user).customer_portal
  end

  def subscription_name
    @subscription_name = Proabono.new(current_user).subscription_name
  end
end
