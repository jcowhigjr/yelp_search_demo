Rails.application.routes.draw do
  # rubocop:disable Metrics/BlockLength
  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    # get '/', to: 'searches#new'
    root to: 'searches#new', as: 'static_home'
    resources :searches, only: %i[new create show update]

    # get 'searches', to: 'searches#create', as: 'new_search'
    # post 'searches', to: 'searches#create', as: 'searches'
    # get 'searches/:id', to: 'searches#show', as: 'search'

    get 'signup', to: 'users#new', as: 'signup'
    resources :users, only: %i[show create]

    resources :users, only: %i[] do
      resources :reviews, only: %i[index edit update destroy]
    end
    resources :reviews, only: :destroy
    resources :user_favorites, only: %i[create destroy]

    resources :coffeeshops, only: :show do
      resources :reviews, only: %i[new create index]
    end

    get '/login', to: 'sessions#new', as: 'login'
    get '/auth/google_oauth2/callback',
        to: 'sessions#create_with_google',
        as: 'google_login'
    post '/sessions', to: 'sessions#create', as: 'sessions'
    delete '/sessions', to: 'sessions#destroy', as: 'logout'
    get '/sessions', to: 'sessions#new', as: 'new_session'
    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  end
  # rubocop:enable Metrics/BlockLength
end
