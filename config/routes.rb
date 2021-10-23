Rails.application.routes.draw do
  root to: 'static#home', as: 'static_home'
  resources :searches, only: %i[new create show]

  resources :users do
    resources :reviews, only: %i[index edit update destroy]
  end

  resources :user_favorites, only: %i[create destroy]

  resources :coffeeshops, only: [:show] do
    resources :reviews, only: %i[new create]
  end

  get '/login', to: 'sessions#new', as: 'login'
  get '/auth/google_oauth2/callback', to: 'sessions#create_with_google', as: 'google_login'
  post '/sessions', to: 'sessions#create', as: 'sessions'
  get '/logout', to: 'sessions#destroy', as: 'logout'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
