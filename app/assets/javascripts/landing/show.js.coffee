$(document).on 'turbolinks:load', ->
  mixpanel.track_forms("#new_search", "Search", { 'query': $("#search_query").val() })
  mixpanel.track_links("#js-getting-started", "Visit getting started")
  
  $("#js-autocomplete").on "click", (event) ->
    alert "Work in progress! Please come back soon"
    mixpanel.track("Autocomplete clicked")
    event.stopPropagation()
    false
    
  false