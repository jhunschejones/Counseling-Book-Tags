Rails.application.routes.draw do
  root 'tags#index'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  post 'password/forgot', to: 'passwords#forgot'
  post 'password/reset', to: 'passwords#reset'
  get 'password/reset', to: 'passwords#new'
  get 'email/verify', to: 'emails#verify'

  resources :users, only: [:new, :show, :edit, :update]
  post 'users/new', to: 'users#create' # POST and GET from the same route to render form errors easliy

  get 'books/search', to: 'books#search'
  resources :books, only: [:index, :show]
  resources :tags, only: [:index, :create, :destroy]
end
