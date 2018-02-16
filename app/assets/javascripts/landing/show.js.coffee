$(document).on 'turbolinks:load', ->
  mixpanel.track("Visit landing")
  mixpanel.track_forms("#js-landing-search", "Search", { 'query': $("#search_query").val() })
  