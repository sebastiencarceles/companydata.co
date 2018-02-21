module Tracking
  Mixpanel = Rails.env.production? ? Mixpanel::Tracker.new(Figaro.env.MIXPANEL_TOKEN) : nil
end
