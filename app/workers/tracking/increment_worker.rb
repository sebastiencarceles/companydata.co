class Tracking::IncrementWorker
  include Sidekiq::Worker

  def perform(user_id, property)
    Tracking::Mixpanel&.people&.increment(user_id, { property => 1 })
  end
end
