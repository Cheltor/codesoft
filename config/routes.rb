Rails.application.routes.draw do
  resources :codes
  devise_for :users
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

  get 'all_violations' => 'addresses#violist'
  get 'my_violations' => 'addresses#my_violations'
  get 'helpful' => 'static#helpful'

  root 'static#dashboard'
  get "sir" => "violations#sir"
  get 'my_citations' => 'citations#my_citations'
  get 'all_citations' => 'citations#all_citations'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
