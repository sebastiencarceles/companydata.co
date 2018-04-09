# frozen_string_literal: true

Rails.application.routes.draw do
  root "landing#show"
  devise_for :users, controllers: { registrations: "registrations" }
  
  get "renew_api_key", to: "users#renew"
  
  post "commands", to: "commands#create"

  resources :companies, only: [:show, :index]  

  namespace :api do
    namespace :v1 do
      get "ping" => "table_tennis#ping"
      resources :companies, only: [:show, :index], param: :identifier do
        collection do
          get "autocomplete", to: "unauth_companies#autocomplete"
        end
        member do
          get "/:registration_2", to: "companies#show_by_registration_numbers"
        end
      end
    end
  end
end
