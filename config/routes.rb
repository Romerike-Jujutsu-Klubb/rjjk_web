# frozen_string_literal: true

Rails.application.routes.draw do
  get 'attendances/form/:year/:month/:group_id' => 'attendances#form'
  post 'image_dropzone/upload'
  get 'info/versjon'
  get 'mitt/oppmote(/:reviewed_attendance_id)' => 'attendances#plan', as: :attendance_plan
  get 'attendances/plan' # must be after "mitt/oppmote"
  post 'attendances/announce(/:year/:week/:group_schedule_id)/:status(/:member_id)' =>
      'attendances#announce'
  get 'login/change_password'
  post 'login/change_password'
  get 'login/forgot_password'
  post 'login/forgot_password'
  match 'login/password' => 'login#login_with_password', as: :login_password, via: %i[get post]
  get 'logout' => 'login#logout', as: :logout
  get 'login' => 'login#login_link_form', as: :login
  post 'login' => 'login#send_login_link', as: :send_login_link
  match 'login/signup', via: %i[get post]
  get 'login/welcome'
  get 'map' => 'map#index'
  get 'member_reports' => 'member_reports#index'
  get 'member_reports/age_chart(/:size)' => 'member_reports#age_chart', as: :member_reports_age_chart
  get 'member_reports/grade_history_graph(/:size)' =>
      'member_reports#grade_history_graph',
      as: :member_reports_grade_history_graph
  get 'member_reports/grade_history_graph_percentage(/:size)' =>
      'member_reports#grade_history_graph_percentage',
      as: :member_reports_grade_history_graph_percentage
  get 'member_reports/history_graph(/:size)' => 'member_reports#history_graph',
      as: :member_reports_history_graph
  get 'pensum' => 'ranks#pensum'
  get 'pensum/pdf' => 'ranks#pdf'
  get 'search' => 'search#index'
  post 'send_grid/receive' => 'send_grid#receive'
  get 'status' => 'status#index'
  get 'svar/:id', controller: :survey_requests, action: :answer_form
  patch 'svar/:id', controller: :survey_requests, action: :save_answers
  post 'svar/:id', controller: :survey_requests, action: :save_answers
  get 'takk/:id', controller: :survey_requests, action: :thanks

  resources :application_steps
  resources :appointments
  resources :annual_meetings
  resources :attendances do
    collection do
      get :form
      get :form_index
      get 'history_graph(/:size)', action: :history_graph
      get 'month_chart(/:year/:month/:size)', action: :month_chart
      get 'month_per_year_chart(/:month/:size)', action: :month_per_year_chart
      get :report
      match 'review/:year/:week/:group_schedule_id/:status', action: :review, via: %i[get post]
      get :since_graduation
    end
    member do
      get :practice_details
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
      get :confirm
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
      post :disapprove
      get :graduates_tab
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

  get 'icon/:width' => 'icons#inline'

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
      get 'inline(/:width).:format', action: :inline, as: :inline
      get 'show(/:width).:format', action: :show
    end
  end
  resources :information_pages, controller: :info, path: :info do
    collection { post :preview }
    member { patch :preview }
  end
  resources :instructor_meetings
  resources :martial_arts
  resources :members do
    collection do
      get :email_list
      get :excel_export
      get :list_active
      get :list_inactive
      get :telephone_list
      get :trial_missing_contract
      get :yaml
    end
    member do
      get :image
      get :missing_contract
      get :photo
      post :save_image
      get :since_graduation
      get :thumbnail
    end
  end

  resources :news_item_likes

  resources :news_items, controller: :news, path: :news do
    collection do
      get :list
      post :preview
    end
    member do
      post :expire
      post :like
      post :move_to_top
      patch :preview
    end
  end

  resources :nkf_members
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
  resources :roles do
    member do
      get :move_up
      get :move_down
    end
  end
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
      post :change_password
      post :forgot_password
      post :like
    end
  end
  resources :wazas

  root to: 'welcome#index'

  get 'documents/*path_info', controller: :documents, action: :webdav
end
