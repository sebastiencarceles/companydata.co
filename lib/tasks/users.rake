# frozen_string_literal: true

namespace :users do
  desc "Init the subscriptions for existing users"
  task init_subscriptions: :environment do
    User.order(:id).each do |user|
      Rails.logger.info "Initializing subscription for #{user.email}"
      proabono = Proabono.new(user)

      Rails.logger.info "Sign up"
      proabono.sign

      if proabono.subscription
        Rails.logger.info "User already has a subscription"
      else
        Rails.logger.info "Subscribe to offer free_trial_existing_users"
        proabono.subscribe("free_trial_existing_users")
        UserMailer.with(user_id: user.id).init_subscription.deliver_later
      end
    end
  end
end
