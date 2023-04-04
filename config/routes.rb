Rails.application.routes.draw do
  resources :codes
  devise_for :users
  root to: "addresses#index"
  resources :addresses do
    resources :violations do
      resources :citations
      patch :resolve, on: :member
      patch :extender, on: :member
      patch :update, on: :member
      get :generate_report, on: :member
    end
    resources :comments
  end
  get "dashboard" => 'static#dashboard'
  get 'violations' => 'addresses#violist'

  get "sir" => "violations#sir"


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
