# frozen_string_literal: true

Rails.application.routes.draw do
  get 'searches/create'

  root "landing#show"
  devise_for :users
  
  get "renew_api_key", to: "users#renew"
  
  resources :searches, only: [:create]
  resources :companies, only: [:show]

  namespace :api do
    get "ping" => "table_tennis#ping"
    resources :companies, only: [:show, :index], param: :identifier
  end
end
