Meddata::Application.routes.draw do
  require 'sidekiq/web'

  resources :articles
  root to: 'articles#index'
  mount Sidekiq::Web => '/sidekiq'
end
