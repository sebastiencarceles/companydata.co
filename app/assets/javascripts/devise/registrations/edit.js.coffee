$(document).on 'turbolinks:load', ->  
  return if $("#subscription-name").length == 0
  $.ajax(url: "/subscription_name")
  
