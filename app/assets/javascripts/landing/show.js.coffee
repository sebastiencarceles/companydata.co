$(document).on 'turbolinks:load', ->
  mixpanel.track_forms("#new_search", "Search", { 'query': $("#js-search-autocomplete").val() })
  mixpanel.track_links("#nav-getting-started", "Visit getting started")
  mixpanel.track_links("#nav-pricing", "Visit pricing")
  mixpanel.track_links("#nav-docs", "Visit docs")
  mixpanel.track_links("#nav-autocomplete", "Visit autocomplete")
