module Tracking
  Mixpanel = Mixpanel::Tracker.new(Figaro.env.MIXPANEL_TOKEN)
end
