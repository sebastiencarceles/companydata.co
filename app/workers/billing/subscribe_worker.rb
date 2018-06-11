# frozen_string_literal: true

class Billing::SubscribeWorker
  include Sidekiq::Worker

  def perform(user_id)
    Proabono.new(User.find(user_id)).subscribe
  end
end
