Rails.application.routes.draw do
  
  get '/', to: "static#home"

  resources :users do
    resources :reviews
  end

  resources :user_favorites, only: [:create, :destroy]
  resources :coffeeshops, only: [:index, :show] do
    resources :reviews, only: [:index]
  end

  get '/login', to: 'sessions#new', as: 'login'
  post 'sessions/', to: 'session#create', as: 'sessions'
  delete 'sessions/', to: 'sessions#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
