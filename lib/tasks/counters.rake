# frozen_string_literal: true

namespace :counters do
  desc "To be scheduled daily: send the counters to Proabono for billing"
  task bill: :environment do
    Counter.unbilled.until_yesterday.each do |counter|
      Rails.logger.info "Send the values to Proabono for billing for counter #{counter.id}"
      counter.bill!
    end
  end
end
