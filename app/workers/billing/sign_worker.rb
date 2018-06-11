# frozen_string_literal: true

class Billing::SignWorker
  include Sidekiq::Worker

  def perform(user_id)
    Proabono.new(User.find(user_id)).sign
  end
end
