# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root "companies#index"

  namespace :api do
    get "ping" => "table_tennis#ping"
    resources :companies, only: [:show, :index], param: :identifier
  end
end
