$(document).on 'turbolinks:load', ->
  mixpanel.track("Visit landing")
  mixpanel.track_forms("#js-landing-search", "Search", { 'query': $("#search_query").val() })
  
  $("#js-autocomplete").on "click", (event) ->
    alert "Work in progress! Please come back soon"
    mixpanel.track("Autocomplete clicked")
    event.stopPropagation()
    false

  engine = new Bloodhound(
    datumTokenizer: (d) ->
      console.log d
      Bloodhound.tokenizers.whitespace d.smooth_name
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/api/v1/companies/autocomplete?q=%QUERY'
      wildcard: '%QUERY')
  promise = engine.initialize()
  promise.done(->
    console.log 'success!'
    return
  ).fail ->
    console.log 'err!'
    return

  $("#js-search-autocomplete").typeahead null,
    name: 'engine'
    displayKey: 'smooth_name'
    source: engine.ttAdapter()

  false