class Tracking::EmailWorker
  include Sidekiq::Worker

  def perform(user_id, email)
    Tracking::Mixpanel&.people&.set(user_id, 'email': email)
  end
end
