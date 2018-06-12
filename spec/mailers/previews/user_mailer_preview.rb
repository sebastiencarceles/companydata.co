# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def init_subscription
    UserMailer.with(user_id: User.first.id).init_subscription
  end

  def no_subscription
    UserMailer.with(user_id: User.first.id).no_subscription
  end

  def missing_payment_method
    UserMailer.with(user_id: User.first.id).missing_payment_method
  end

  def unpaid_invoices
    UserMailer.with(user_id: User.first.id).unpaid_invoices
  end
end
