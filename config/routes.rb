# frozen_string_literal: true

Rails.application.routes.draw do
  root "landing#show"
  devise_for :users
  
  get 'companies/index'

  resources :companies, only: [:show, :index]

  namespace :api do
    get "ping" => "table_tennis#ping"
    resources :companies, only: [:show, :index], param: :identifier
  end
end
