# frozen_string_literal: true

Rails.application.routes.draw do
  root "companies#index"
  post "user_token" => "user_token#create"
  get "ping" => "table_tennis#ping"

  namespace :api do
    resources :companies, only: :show
  end
end
