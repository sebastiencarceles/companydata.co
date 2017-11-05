# frozen_string_literal: true

Rails.application.routes.draw do
  root "companies#index"

  resources :users, only: [:new, :create, :show]

  namespace :api do
    post "user_token" => "user_token#create"
    get "ping" => "table_tennis#ping"
    resources :companies, only: [:show, :index], param: :identifier
  end
end
