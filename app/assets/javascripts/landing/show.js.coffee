$(document).on 'turbolinks:load', ->
  mixpanel.track("Visit landing")
  mixpanel.track_forms("#js-landing-search", "Search", { 'query': $("#search_query").val() })
  
  $("#js-autocomplete").on "click", (event) ->
    alert "Work in progress! Please come back soon"
    mixpanel.track("Autocomplete clicked")
    event.stopPropagation()
    false
    
  false