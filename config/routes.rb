# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options Rails.application.config.action_mailer.default_url_options

  get 'attendances/form/:year/:month/:group_id' => 'attendances#form'
  post 'image_dropzone/upload'
  get 'info/versjon'
  get 'mitt/oppmote(/:reviewed_attendance_id)' => 'attendances#plan', as: :attendance_plan
  get 'attendances/plan' # must be after "mitt/oppmote"
  post 'attendances/announce(/:year/:week/:group_schedule_id)/:status(/:member_id)' =>
      'attendances#announce'
  get 'map' => 'map#index'
  get 'pensum' => 'ranks#pensum'
  get 'pensum/pdf' => 'ranks#pdf'
  get 'search' => 'search#index'
  post 'send_grid/receive' => 'send_grid#receive'
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
      get :history_graph, action: :history_graph
      get :history_graph_data, action: :history_graph_data
      get 'month_chart(/:year/:month)', action: :month_chart, as: :month_chart
      get 'month_chart_data(/:year/:month)', action: :month_chart_data, as: :month_chart_data
      get 'month_per_year_chart(/:month)', action: :month_per_year_chart, as: :month_per_year_chart
      get 'month_per_year_chart_data(/:month)', action: :month_per_year_chart_data,
          as: :month_per_year_chart_data
      get 'report(/:year/:month)', action: :report, as: :report
      match 'review/:year/:week/:group_schedule_id/:status', action: :review, via: %i[get post]
      get :since_graduation
    end
    member do
      get :practice_details
    end
  end
  resources :attendance_notifications, only: :index do
    collection do
      post :push
      post :subscribe
    end
  end
  resources :attendance_webpushes
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

  controller :login do
    match 'login/change_password', action: :change_password, via: %i[get post], as: :change_password
    match 'login/forgot_password', action: :forgot_password, via: %i[get post], as: :forgot_password
    get 'login/link_message_sent', action: :login_link_message_sent, as: :login_link_message_sent
    match 'login/password', action: :login_with_password, via: %i[get post], as: :login_password
    match 'login/signup', via: %i[get post]
    get 'login/welcome'
    get 'login', action: :login_link_form, as: :login
    post 'login', action: :send_login_link, as: :send_login_link
    get 'logout', action: :logout, as: :logout
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
      get 'graduates_list/:section', action: :graduates_list, as: :graduates_list
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
    member do
      get :gallery
      get 'inline(/:width).:format', action: :inline, as: :inline
      get 'show(/:width).:format', action: :show, as: :show
    end
    collection do
      get :gallery
      get :mine
      post :upload
      get 'inline/:id(/:width).:format', action: :inline
      get 'show/:id(/:width).:format', action: :show
    end
  end
  resources :information_pages, controller: :info, path: :info do
    collection { post :preview }
    member { patch :preview }
  end
  resources :instructor_meetings
  resources :martial_arts

  controller :member_reports do
    get 'member_reports', action: :index
    get 'member_reports/age_chart', action: :age_chart, as: :member_reports_age_chart
    get 'member_reports/age_chart_data', action: :age_chart_data, as: :member_reports_age_chart_data
    get 'member_reports/grade_history_graph(/:size)', action: :grade_history_graph,
        as: :member_reports_grade_history_graph
    get 'member_reports/grade_history_graph_data', action: :grade_history_graph_data,
        as: :member_reports_grade_history_graph_data
    get 'member_reports/grades_graph_data', action: :grades_graph_data,
        as: :member_reports_grades_graph_data
    get 'member_reports/history_graph(/:size)', action: :history_graph,
        as: :member_reports_history_graph
    get 'member_reports/history_graph_data', action: :history_graph_data,
        as: :member_reports_history_graph_data
  end

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

  controller :status do
    get 'status', action: :index
    get 'status/gc', action: :gc
    get 'status/heap_dump', action: :heap_dump
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
      get :photo
    end
  end
  resources :wazas

  root to: 'welcome#index'

  get 'documents/*path_info', controller: :documents, action: :webdav
end
