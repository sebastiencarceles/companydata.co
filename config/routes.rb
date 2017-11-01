# frozen_string_literal: true

Rails.application.routes.draw do
  post "user_token" => "user_token#create"
  root "companies#index"

  get "ping" => "table_tennis#ping"
end
