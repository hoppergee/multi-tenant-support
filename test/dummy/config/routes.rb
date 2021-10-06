Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users

  namespace :super_admin do
    resource :dashboard, controller: :dashboard
  end

  namespace :api do
    resources :users
  end
end
