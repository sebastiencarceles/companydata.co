$ ->
  mixpanel.track_links("#js-choose-free", "Choose plan", { 'plan': 'free' })
  mixpanel.track_links("#js-choose-normal", "Choose plan", { 'plan': 'normal' })
  mixpanel.track_links("#js-choose-huge", "Choose plan", { 'plan': 'huge' })
  mixpanel.track_links("#js-choose-unlimited", "Choose plan", { 'plan': 'unlimited' })
  