# frozen_string_literal: true

class Billing::IncrementWorker
  include Sidekiq::Worker

  def perform(user_id, value)
    case Proabono.new(User.find(user_id)).increment_by(value)
    when nil
      Rails.logger.info "#{value} calls sent to billing for user #{user_id}"
    when "Error.Api.Usage.NoneMatching"
      
    end
  end
end
