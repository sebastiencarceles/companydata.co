# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "landing#show"
  devise_for :users, controllers: { registrations: "registrations" }
  
  get "renew_api_key", to: "users#renew"
  
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
      resources :vats, only: :show, param: :value
      resources :commands, only: :create
    end
    
    namespace :admin do
      resources :vats, only: :update do 
        collection do
          get "to_check", to: "vats#to_check"
        end
      end
    end
  end
end
