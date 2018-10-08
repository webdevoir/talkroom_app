Rails.application.routes.draw do
  root 'static_pages#home'
  get 'article/:article_id/like', to: 'articles#like'
  resources :rooms, :only => [:index, :show, :new, :create]
  resources :users, :only => [:edit, :update, :destroy]
  resources :chat_rooms, :only => [:show, :create, :destroy, :index]
  resources :articles, :only => [:new, :create, :index, :show]

  mount ActionCable.server => '/cable'
end
