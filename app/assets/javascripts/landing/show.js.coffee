$(document).on 'turbolinks:load', ->
  mixpanel.track("Visit landing")
#   mixpanel.track_links("#js-landing-search", "Search", { 'query': $("#search_query").val() })
  