$(document).on 'turbolinks:load', ->
  mixpanel.track("Visit payment")
  