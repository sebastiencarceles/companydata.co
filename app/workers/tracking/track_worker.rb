# frozen_string_literal: true

class Tracking::TrackWorker
  include Sidekiq::Worker

  def perform(user_id, property)
    Tracking::Mixpanel&.track(user_id, property)
  end
end
