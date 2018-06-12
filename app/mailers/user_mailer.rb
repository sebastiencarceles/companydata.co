# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :find_user

  def init_subscription
    mail to: @user.email
  end

  def no_subscription
    mail to: @user.email
  end

  def missing_payment_method
    mail to: @user.email
  end

  def unpaid_invoices
    mail to: @user.email
  end

  private
    def find_user
      @user = User.find(params[:user_id])
    end
end
