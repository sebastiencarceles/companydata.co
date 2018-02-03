# frozen_string_literal: true

Rails.application.routes.draw do
  root "landing#show"
  devise_for :users, controllers: { registrations: "registrations" }
  
  get 'searches/create'
  get "renew_api_key", to: "users#renew"
  get "pricing", to: "pricing#show"
  post "pricing", to: "pricing#choose"

  resources :searches, only: [:create]
  resources :companies, only: [:show]

  namespace :api do
    namespace :v1 do
      get "ping" => "table_tennis#ping"
      resources :companies, only: [:show, :index], param: :identifier
    end
  end
end
