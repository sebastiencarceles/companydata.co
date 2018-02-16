$(document).on 'ready page:load turbolinks:load', ->
  mixpanel.track("Visit payment")
  