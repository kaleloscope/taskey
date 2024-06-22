Rails.application.routes.draw do
  get 'home/index'
  # get 'tasks/index'
  resources :tasks

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
