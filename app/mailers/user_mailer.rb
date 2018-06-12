# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def init_subscription
    @user = params[:user]
    mail to: @user.email
  end

  def no_subscription
    @user = params[:user]
    mail to: @user.email
  end
end
