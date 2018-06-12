# frozen_string_literal: true

class Billing::IncrementWorker
  include Sidekiq::Worker

  def perform(user_id, value)
    case Proabono.new(User.find(user_id)).increment_by(value)[:Code]
    when nil
      Rails.logger.info "#{value} calls sent to billing for user #{user_id}"
    when "Error.Api.Usage.NoneMatching"
      UserMailer.with(user_id: user_id).no_subscription.deliver_later
    when "Error.Customer.PaymentSettings.Missing"
      UserMailer.with(user_id: user_id).missing_payment_method.deliver_later
    when "Error.Customer.Billing.CappingReached"
      UserMailer.with(user_id: user_id).unpaid_invoices.deliver_later
    else
      raise "Unknown case! Unable to send calls to value for user #{user_id}"
    end
  end
end
