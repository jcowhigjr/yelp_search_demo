Rails.application.routes.draw do
  
  
  root to: "static#home"
  resources :searches, only: [:new, :create, :show]

  resources :users do
    resources :reviews, only: [:index, :edit, :update, :destroy]
  end

  resources :user_favorites, only: [:create, :destroy]

  resources :coffeeshops, only: [:show] do
    resources :reviews, only: [ :new, :create]
  end

  get '/login', to: 'sessions#new', as: 'login'
  get '/auth/google_oauth2/callback', to: "sessions#create_with_google"
  post '/sessions', to: 'sessions#create', as: 'sessions'
  delete '/sessions', to: 'sessions#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
