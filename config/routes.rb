Rails.application.routes.draw do
  root "companies#index"
  get 'scrap' => 'companies#scrap'
end
