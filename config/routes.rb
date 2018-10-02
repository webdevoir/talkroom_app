Rails.application.routes.draw do
  root 'static_pages#home'
  resources :rooms, :only => [:index, :show, :new, :create]
  resources :users, :only => [:edit, :update, :destroy]
  resources :chat_rooms, :only => [:show, :create, :destroy, :index]
  resources :articles, :only => [:new, :create, :index, :show, :like]

  mount ActionCable.server => '/cable'
end
