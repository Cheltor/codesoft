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
    resources :units, only: [:new, :create, :edit, :update, :destroy, :index, :show] do
      member do
        get 'all_unit_comments'
        get 'all_unit_violations'
        get 'all_unit_citations'
        get 'all_unit_inspections'
        get 'all_unit_complaints'
        get 'manage_contacts'
        post 'manage_contacts'
        delete 'remove_contact'
        get :set_potentially_vacant
        get :set_vacant
        get :set_occupied
      end
    end
    resources :inspections do
      member do
        get 'conduct'
        get 'schedule'
        post 'save_and_redirect_to_area_new'
        get 'create_business_license'
        get 'create_single_family_license'
      end
      resources :areas do
        resources :observations, only: [:create, :edit, :update]
      end
      resources :inspection_comments
      resources :licenses, except: [:index]
    end
    resources :businesses, except: [:index, :new_business]
    member do
      get 'manage_contacts'
      post 'manage_contacts'
      delete 'remove_contact'
      get 'address_name'
      get 'all_address_violations'
      get 'all_address_comments'
      get 'all_address_citations'
      get 'all_address_inspections'
      get 'all_address_complaints'
      get 'add_aka'
      get :set_potentially_vacant
      get :set_vacant
      get :set_occupied
    end
    collection do
      get :potentially_vacant
      get :vacant
    end
  end

  resources :licenses do
    get 'email_license' => 'licenses#email_license'
    get 'download_license' => 'licenses#download_license'
    member do
      put 'sent_today' => 'licenses#sent_today' 
      put 'not_sent' => 'licenses#not_sent'
      get 'generate_business'
      get 'generate_single_family'
    end
  end

  get 'all_inspections' => 'inspections#all_inspections'
  get 'my_inspections' => 'inspections#my_inspections'
  get 'my_unscheduled_inspections' => 'inspections#my_unscheduled_inspections'
  get 'all_complaints' => 'inspections#all_complaints'
  get 'my_complaints' => 'inspections#my_complaints'
  get 'all_violations' => 'violations#violist'
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
  get 'inspection_calendar' => 'inspections#inspection_calendar'
  get 'new_business_violation/:business_id' => 'violations#new_business_violation', as: 'new_business_violation'
  get 'all_licenses' => 'licenses#index'

  resources :users, only: [:index, :show, :edit, :update]
  resources :notifications do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end

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
      resources :businesses
      resources :complaints
      resources :inspections
      resources :violations
      resources :codes
      resources :contacts
    end
  end
  mount ServiceWorker::Engine => "/service-worker.js"
end
