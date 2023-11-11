Rails.application.routes.draw do
  resources :codes
  resources :contacts do
    resources :contact_comments
    member do
      get 'add_notes'
      patch :hide
    end
  end
  devise_for :users
  resources :addresses do
    resources :violations, shallow: true do
      resources :citations, shallow: true do
        resources :citation_comments
      end
      member do
        get :extend_deadline
        patch :update_deadline
      end
      patch :resolve, on: :member
      patch :update, on: :member
      get :generate_report, on: :member
      resources :violation_comments
    end
    resources :comments
    resources :concerns, only: [:create, :edit, :update]
    resources :units, only: [:new, :create, :edit, :update, :destroy, :index, :show]
    resources :inspections do
      member do
        get 'conduct'
        get 'schedule'
        post 'save_and_redirect_to_area_new'
      end
      resources :areas
      resources :inspection_comments
    end
    resources :businesses, except: [:index, :new_business]
    member do
      get 'manage_contacts'
      post 'manage_contacts'
      get 'address_name'
    end
  end

  get 'all_inspections' => 'inspections#all_inspections'
  get 'my_inspections' => 'inspections#my_inspections'
  get 'my_unscheduled_inspections' => 'inspections#my_unscheduled_inspections'
  get 'all_complaints' => 'inspections#all_complaints'
  get 'my_complaints' => 'inspections#my_complaints'
  get 'all_violations' => 'addresses#violist'
  get 'my_violations' => 'addresses#my_violations'
  get 'helpful' => 'static#helpful'
  get 'businesses' => 'businesses#index'
  patch 'mark_reviewed/:id' => 'static#mark_reviewed', as: 'mark_reviewed'
  get 'design_test' => 'static#design_test'
  get 'new_business' => 'businesses#new_business'
  post 'new_business' => 'businesses#create_business'
  get 'new_complaint' => 'inspections#new_complaint'
  post 'new_complaint' => 'inspections#create_complaint'
  get 'new_permit_inspection' => 'inspections#new_permit_inspection'
  post 'new_permit_inspection' => 'inspections#create_permit_inspection'
  get 'new_license_inspection' => 'inspections#new_license_inspection'
  post 'new_license_inspection' => 'inspections#create_license_inspection'
  get 'unassigned_inspections' => 'inspections#unassigned_inspections'
  get 'assign_inspection/:id' => 'inspections#assign_inspection', as: 'assign_inspection'
  patch 'update_inspector/:id' => 'inspections#update_inspector', as: 'update_inspector'


  resources :users, only: [:index, :show, :edit, :update]

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

  namespace :api do
    namespace :v1 do
      resources :addresses
    end
  end
  mount ServiceWorker::Engine => "/service-worker.js"


end
