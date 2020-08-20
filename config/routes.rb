Rails.application.routes.draw do
  
  root to: "static#home"
  get '/search', to: "static#search", as: 'search'

  resources :users do
    resources :reviews
  end

  resources :user_favorites, only: [:create, :destroy]
  resources :coffeeshops, only: [:index, :show] do
    resources :reviews, only: [:index]
  end

  get '/login', to: 'sessions#new', as: 'login'
  get '/auth/google_oauth2/callback', to: "sessions#create_with_google"
  post 'sessions/', to: 'session#create', as: 'sessions'
  delete 'sessions/', to: 'sessions#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
