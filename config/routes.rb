Rails.application.routes.draw do
  root 'tags#index'
  resources :books, only: [:index, :show]
  resources :tags, only: [:index, :create, :destroy]
end
