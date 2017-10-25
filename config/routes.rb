Rails.application.routes.draw do

  resources :users
  get '/:id/devices/' => 'devices#show'
  get '/:id/devices/register' => 'devices#register'
  get '/:id/devices/details/:devid' => 'devices#details'
  match '/:id/devices/update_details/:devid' => 'devices#update_details', :via => :post
  get '/:id/devices/adddevice' => 'devices#adddevice'
  get '/:id/captures' => 'captures#index'
  get '/:id/captures/show/:capture_id' => 'captures#show'
  get '/:id/captures/delete/:capture_id' => 'captures#delete'
  get '/:id/captures/uploadsuccess/:capture_id' => 'captures#uploadsuccess'
  get '/:id/captures_line_graph/show_all_sensors/:capture_id' => 'captureslinegraphcontroller#show_all_sensors'
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
