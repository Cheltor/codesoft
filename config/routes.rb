Rails.application.routes.draw do
  resources :codes
  devise_for :users
  resources :addresses do
    resources :violations, shallow: true do
      resources :citations, shallow: true
      patch :resolve, on: :member
      patch :extender, on: :member
      patch :update, on: :member
      get :generate_report, on: :member
    end
    resources :comments
    resources :concerns, only: [:create, :edit, :update]
  end

  get 'all_violations' => 'addresses#violist'
  get 'my_violations' => 'addresses#my_violations'
  get 'helpful' => 'static#helpful'

  authenticated :user, ->(u) { u.admin? } do
    root 'static#admin', as: :admin_root
  end
  unauthenticated do
    root 'static#issue', as: :unauthenticated_root
  end
  root 'static#dashboard'
  get "sir" => "violations#sir"
  get 'my_citations' => 'citations#my_citations'
  get 'all_citations' => 'citations#all_citations'
  get 'admin_user' => 'static#admin_user'
  put "/update_user/:id", to: "static#update_user", as: "update_user"


end
