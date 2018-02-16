$ ->
  $(".js-choose").on "click", (event) ->
    form = $(this).closest("form")
    plan = form.find("#pricing_plan").val()
    Mixpanel.track(plan + "plan")