Rails.application.routes.draw do
  
  devise_for :users

  root "products#index"
  resources :products do
    resources :subscribers, only: [ :create ]
  end
  resource :unsubscribe, only: [ :show ]


end