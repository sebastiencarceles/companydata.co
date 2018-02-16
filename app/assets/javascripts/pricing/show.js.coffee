$(document).on 'turbolinks:load', ->
  mixpanel.track_forms("#js-choose-free", "Choose plan", { 'plan': 'free' })
  mixpanel.track_forms("#js-choose-normal", "Choose plan", { 'plan': 'normal' })
  mixpanel.track_forms("#js-choose-huge", "Choose plan", { 'plan': 'huge' })
  mixpanel.track_forms("#js-choose-unlimited", "Choose plan", { 'plan': 'unlimited' })
  