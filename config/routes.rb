Rails.application.routes.draw do
  get 'captures/uploadsuccess'

  resources :users
  get '/:id/devices/' => 'devices#show'
  get '/:id/devices/register' => 'devices#register'
  get '/:id/devices/details/:devid' => 'devices#details'
  get '/:id/devices/adddevice' => 'devices#adddevice'
  get '/:id/captures' => 'captures#index'
  get '/:id/captures/show/:capture_id' => 'captures#show'
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
