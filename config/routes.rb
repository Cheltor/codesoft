Rails.application.routes.draw do
  devise_for :users
  root to: "addresses#index"
  resources :addresses, only: [:index, :show] do
    resources :comments
  end
  get "static/home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
