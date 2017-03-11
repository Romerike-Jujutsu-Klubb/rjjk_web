# frozen_string_literal: true
Rails.application.routes.draw do
  get 'attendances/form/:year/:month/:group_id' => 'attendances#form'
  get 'info/versjon'
  get 'members/search'
  get 'mitt/oppmote' => 'attendances#plan', as: :attendance_plan
  get 'attendances/plan' # must be after "mitt/oppmote"
  post 'attendances/announce(/:year/:week/:group_schedule_id)/:status(/:member_id)' =>
      'attendances#announce'
  get 'login/change_password'
  post 'login/change_password'
  get 'login/forgot_password'
  post 'login/forgot_password'
  match 'login' => 'login#login', as: :login, via: [:get, :post]
  get 'login/logout'
  match 'login/signup', via: [:get, :post]
  get 'login/welcome'
  get 'news/list'
  post 'news/expire' => 'news#expire'
  get 'pensum' => 'ranks#pensum'
  get 'pensum/pdf' => 'ranks#pdf'
  get 'search' => 'search#index'
  get 'svar/:id', controller: :survey_requests, action: :answer_form
  patch 'svar/:id', controller: :survey_requests, action: :save_answers
  post 'svar/:id', controller: :survey_requests, action: :save_answers
  get 'takk/:id', controller: :survey_requests, action: :thanks

  resources :application_steps do
    member do
      get :image
    end
  end
  resources :appointments
  resources :annual_meetings
  resources :attendances do
    collection do
      get :form
      get :form_index
      get :history_graph
      get :month_chart
      get :month_per_year_chart
      get :report
      match 'review/:year/:week/:group_schedule_id/:status', action: :review, via: [:get, :post]
      get :since_graduation
    end
  end
  resources :basic_technique_links
  resources :basic_techniques
  resources :birthday_celebrations do
    member { get :certificates }
  end
  resources :board_meetings do
    member do
      get :minutes
    end
  end
  resources :censors do
    get :confirm, on: :member
    get :decline, on: :member
  end
  resources :cms_members do
    collection do
      get :active_contracts
    end
  end
  resources :correspondences
  resources :elections
  resources :embus do
    member do
      get :print
    end
  end
  resources :embu_images
  resources :event_invitee_messages
  resources :event_invitees
  resources :event_messages
  resources :events do
    collection do
      get :attendance_form
    end
    get :calendar, on: :collection
    get :calendar, on: :member
    get :invite, on: :member
  end
  resources :graduates do
    member do
      post :confirm
      get :decline
    end
  end
  resources :graduations do
    member do
      patch :add_group
      post :approve
      get :censor_form
      get :censor_form_pdf
      get :certificates
      post :lock
    end
  end
  resources :group_instructors
  resources :group_schedules
  resources :group_semesters
  resources :groups do
    collection do
      get :yaml
    end
  end
  resources :images do
    collection do
      get :gallery
      get :mine
      post :upload
      get 'inline/:id(/:width).:format', action: :inline
      get 'show/:id(/:width).:format', action: :show
    end
    member do
      get :gallery
    end
  end
  resources :information_pages, controller: :info, path: :info
  resources :instructor_meetings
  resources :martial_arts
  resources :members do
    collection do
      get :cms_comparison
      get :email_list
      get :excel_export
      get :grade_history_graph
      get :grade_history_graph_percentage
      get :history_graph
      get :income
      get :list_active
      get :list_inactive
      get :nkf_report
      get :report
      get :telephone_list
      get :trial_missing_contract
      get :yaml
    end
    member do
      get :age_chart
      get :grade_history_graph
      get :grade_history_graph_percentage
      get :history_graph
      get :image
      get :missing_contract
      get :since_graduation
      get :thumbnail
    end
  end
  resources :news_items, controller: :news, path: :news
  resources :nkf_members do
    collection do
      get :comparison
      post :create_member
      get :import
      post :import
    end
    member do
      post :update_member
    end
  end
  resources :nkf_member_trials
  resources :page_aliases
  resources :practices
  resources :public_records
  resources :ranks do
    member do
      get :card
    end
  end
  resources :raw_incoming_emails
  resources :roles
  resources :semesters
  resources :signatures do
    member do
      get :image
    end
  end
  resources :survey_answer_translations
  resources :survey_answers
  resources :survey_questions
  resources :survey_requests
  resources :surveys
  resources :technique_applications
  resources :trial_attendances
  resources :user_messages
  resources :users do
    member do
      post :like
    end
  end
  resources :wazas

  root to: 'welcome#index'

  get 'documents/*path_info', controller: :documents, action: :webdav
end
