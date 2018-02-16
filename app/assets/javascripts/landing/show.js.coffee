$(document).on 'turbolinks:load', ->
  mixpanel.track("Visit landing")
  mixpanel.track_forms("#js-landing-search", "Search", { 'query': $("#search_query").val() })
  
  $("#js-work-in-progress").on "click", (event) ->
    alert "Work in progress! Please come back soon"
    event.stopPropagation()
    false
    
  false