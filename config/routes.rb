# frozen_string_literal: true

Rails.application.routes.draw do
  root "landing#show"
  devise_for :users
  
  resources :companies, only: [:show] do
    collection do
      get 'search', to: "companies#search" # TODO is it possible to avoid the "to" part
    end
  end

  namespace :api do
    get "ping" => "table_tennis#ping"
    resources :companies, only: [:show, :index], param: :identifier
  end
end
