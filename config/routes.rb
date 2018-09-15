Rails.application.routes.draw do
  root 'static_pages#home'
  # get '/rooms/show', to: 'rooms#show'
  # get '/rooms', to: 'rooms#index'
  post '/users/create', to: 'users#create'
  patch '/users/update', to: 'users#update'
  resources :rooms, :only => [:index, :show, :new, :create]

  mount ActionCable.server => '/cable'
end
