Rails.application.routes.draw do
  resources :users
  get '/:id/devices/' => 'devices#show'
  get '/:id/devices/register' => 'devices#register'
  get '/:id/devices/details/:devid' => 'devices#details'
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
