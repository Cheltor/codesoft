Rails.application.routes.draw do
  resources :codes
  devise_for :users
  root to: "addresses#index"
  resources :addresses do
    resources :comments
    patch :toggle_outstanding_violation, on: :member
  end
  get "static/home"
  get 'violations' => 'addresses#violist'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
