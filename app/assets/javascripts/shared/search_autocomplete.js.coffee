$(document).on 'turbolinks:load', ->  
  engine = new Bloodhound(
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace d.smooth_name
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/api/v1/companies/autocomplete?q=%QUERY'
      wildcard: '%QUERY'
  )
  engine.initialize()
  
  $("#js-search-autocomplete").typeahead(null,
    name: 'engine'
    displayKey: 'smooth_name'
    source: engine.ttAdapter()
    templates:
      suggestion: Handlebars.compile("
        <div>
          {{smooth_name}}
          <small>
            {{city}}
            {{country}}
          </small>
        </div>
      ")
  ).on 'typeahead:selected', (e, data) ->
    $(this).closest('form').submit()
    return
    
  false