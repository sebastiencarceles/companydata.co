namespace :users do
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
        UserMailer.with(user: user).init_subscription.deliver_later
      end
    end
  end
end
