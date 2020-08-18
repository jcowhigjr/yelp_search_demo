Rails.application.routes.draw do
  get 'user_favorites/create'
  get 'user_favorites/destroy'
  resources :reviews
  resources :users
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
  get 'static/home'
  get 'static/search'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
