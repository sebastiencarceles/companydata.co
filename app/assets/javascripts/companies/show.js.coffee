$(document).on 'turbolinks:load', ->
  mixpanel.track_links("#nav-getting-started", "Visit getting started")
