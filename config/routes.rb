# frozen_string_literal: true

Rails.application.routes.draw do
  root "landing#show"
  devise_for :users, controllers: { registrations: "registrations" }
  
  get "renew_api_key", to: "users#renew"
  get "pricing", to: "pricing#show"
  post "pricing", to: "pricing#choose"
  get "payment", to: "payment#show"
  
  resources :searches, only: [:new, :create, :index]
  resources :companies, only: [:show, :index]

  namespace :api do
    namespace :v1 do
      get "ping" => "table_tennis#ping"
      resources :companies, only: [:show, :index], param: :identifier do
        collection do
          get "autocomplete", to: "unauth_companies#autocomplete"
        end
      end
    end
  end
end
