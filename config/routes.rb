require 'sidekiq/web'

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  namespace :api do
    resources :users, only: [:index, :show, :create], controller: :users
  end
  mount Sidekiq::Web => '/sidekiq'
end
