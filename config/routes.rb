Rails.application.routes.draw do
  root to: "static#home"

  resources :users do
    resources :reviews
  end

  resources :user_favorites, only: [:create, :destroy]
  resources :coffeeshops, only: [:show, :index] do
    resources :reviews, only: [:index]
  end

  get 'sessions/new', to: 'sessions#new', as: 'login'
  post 'sessions/create', to: 'session#create'
  delete 'sessions/destroy', to: 'sessions#destroy', as: 'logout'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
