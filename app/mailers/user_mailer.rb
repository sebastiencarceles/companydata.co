# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def init_subscription
    @user = User.find(params[:user_id])
    mail to: @user.email
  end

  def no_subscription
    @user = User.find(params[:user_id])
    mail to: @user.email
  end
end
