Rails.application.routes.draw do
  root 'static_pages#home'
  resources :rooms, :only => [:index, :show, :new, :create]
  resources :users, :only => [:edit, :update, :destroy]

  mount ActionCable.server => '/cable'
end
