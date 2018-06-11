# frozen_string_literal: true

class Billing::IncrementWorker
  include Sidekiq::Worker

  def perform(user_id)
    Proabono.new(User.find(user_id)).increment
  end
end
