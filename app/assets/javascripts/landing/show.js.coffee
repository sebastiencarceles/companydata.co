$(document).on 'turbolinks:load', ->
  mixpanel.track_forms("#new_search", "Search", { 'query': $("#js-search-autocomplete").val() })
  mixpanel.track_links("#js-getting-started", "Visit getting started")
  mixpanel.track_links("#nav-pricing", "Visit pricing")
  mixpanel.track_links("#nav-docs", "Visit docs")
    
  $("#js-autocomplete").on "click", (event) ->
    alert "Work in progress! Please come back soon"
    mixpanel.track("Autocomplete clicked")
    event.stopPropagation()
    false

  false