# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options Rails.application.config.action_mailer.default_url_options

  post 'image_dropzone/upload'

  # FIXME(uwe): Separate to MyAttendanceController
  get 'mitt/oppmote(/:reviewed_attendance_id)' => 'attendances#plan', as: :attendance_plan
  get 'attendances/plan' # must be after "mitt/oppmote"
  post 'attendances/announce(/:year/:week/:group_schedule_id)/:status(/:user_id)' =>
      'attendances#announce', as: :announce_attendance
  # EMXIF

  get 'map' => 'map#index'
  get 'search' => 'search#index'
  post 'send_grid/receive' => 'send_grid#receive'
  get 'svar/:id', controller: :survey_requests, action: :answer_form
  patch 'svar/:id', controller: :survey_requests, action: :save_answers
  post 'svar/:id', controller: :survey_requests, action: :save_answers
  get 'takk/:id', controller: :survey_requests, action: :thanks
  get 'velkommst' => 'welcome#front_parallax', as: :front_parallax

  resources :application_image_sequences
  resources :application_steps do
    member do
      patch :move_up
      patch :move_down
    end
  end
  resources :application_videos
  resources :appointments
  resources :annual_meetings
  scope controller: :attendance_form, path: 'oppmøte/skjema' do
    root action: :index, as: :attendance_forms
    get 'group/:id', action: :group, as: :attendance_group
    get ':year/:month/:group_id', action: :show, as: :attendance_form
  end
  resources :attachments, only: :destroy
  resources :attendances do
    collection do
      get :history_graph, action: :history_graph
      get :history_graph_data, action: :history_graph_data
      get 'month_chart(/:year/:month)', action: :month_chart, as: :month_chart
      get 'month_chart_data(/:year/:month)', action: :month_chart_data, as: :month_chart_data
      get 'month_per_year_chart(/:month)', action: :month_per_year_chart, as: :month_per_year_chart
      get 'month_per_year_chart_data(/:month)', action: :month_per_year_chart_data,
          as: :month_per_year_chart_data
      get 'report(/:year/:month)', action: :report, as: :report
      match 'review/:year/:week/:group_schedule_id/:status(/:user_id)', action: :review,
          via: %i[get post]
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
  get 'audit/index/:item_type/:item_id' => 'audit#index', as: :audit
  resources :basic_techniques
  resources :birthday_celebrations do
    member { get :certificates }
  end
  resources :board_meetings do
    member do
      get :minutes
    end
  end
  resources :card_keys
  resources :censors do
    match :accept, on: :member, via: %i[get post] # GET from emails
    match :decline, on: :member, via: %i[get post] # GET from emails
  end

  resources :correspondences
  resources(:curriculums, path: :pensum, only: %i[index show]) { collection { get :card_pdf } }
  resources(:curriculum_groups)
  resources :elections
  resources :embus do
    member do
      get :print
    end
  end
  resources :embu_images
  resources :embu_part_videos
  resources :embu_parts
  resources :event_invitee_messages
  resources :event_invitees
  resources :event_registration, path: 'event/registration' do
    member do
      post :accept
      post :decline
      get :will_work
      get :will_not_work
    end
  end
  resources :event_messages do
    collection do
      get :template
    end
  end
  resources :events do
    collection do
      get :attendance_form
      get :calendar
      post :preview
    end
    member do
      post :add_org
      post :accept
      get :calendar
      post :decline
      post :invite
      get :preview
      patch :preview
      post :preview
      get :tentative
    end
  end
  resources :external_events do
    member do
      post :accept
      post :decline
    end
  end

  resources :front_page_sections
  resources :graduates do
    member do
      match :accept, via: %i[get post] # GET from emails
      match :decline, via: %i[get post] # GET from emails
    end
  end
  resources :graduations do
    member do
      post :accept
      patch :add_group
      post :approve
      get :censor_form
      get :censor_form_pdf
      get :certificates
      post :decline
      post :disapprove
      get 'graduates_list/:section', action: :graduates_list, as: :graduates_list
      post :lock
      patch :send_date_change_message
      get :tentative
    end
  end
  resources :group_instructors
  resources :group_schedules
  resources :group_semesters
  resources :groups

  get 'icon/notification' => 'icons#notification_icon'
  get 'icon/:width' => 'icons#inline'

  resources :images do
    member do
      get :gallery
      get :blurred
      get 'inline(/:width)(.:format)', action: :inline, as: :inline
      get 'show(/:width)(.:format)', action: :show, as: :show
      patch :reset_google_drive_reference
    end
    collection do
      get :gallery
      get :mine
      post :upload
      get 'inline/:id(/:width)(.:format)', action: :inline
      get 'show/:id(/:width)(.:format)', action: :show
    end
  end
  get 'ims/index'
  post 'ims/import'
  resources :information_pages, controller: :info, path: :info do
    collection { post :preview }
    member do
      get :move_up
      get :move_down
      patch :preview
    end
  end
  resources :instructor_meetings do
    member do
      post :accept
      post :decline
    end
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

  resources(:martial_arts) { member { post :copy } }

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
    end
    member do
      get :since_graduation
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
  resources :page_aliases
  resources :practices
  resources :price_age_groups
  resources :profile, only: %i[index update] do
    collection do
      get :photo
      post :save_image
    end
  end
  resources :public_records
  resources :rank_articles
  resources :ranks do
    member do
      get :card
      get :card_pdf
      get :pdf
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

  scope controller: :signup_guide, as: :signup_guide, path: 'innmelding' do
    root action: :basics
    match :basics, via: %i[get post]
    match :contact_info, via: %i[get post]
    match :guardians, via: %i[get post]
    match :groups, via: %i[get post]
    match :welcome_package, via: %i[get post]
    post :complete
    patch :complete
    get :find_user
  end

  resources :signups do
    member do
      patch :complete
      delete :terminate
    end
  end
  resources :sms, only: %i[index show create]

  controller :status do
    get 'status', action: :index
    get 'status/health', action: :health
  end

  resources :survey_answer_translations
  resources :survey_answers
  resources :survey_questions
  resources :survey_requests
  resources :surveys
  resources :technique_applications do
    collection do
      get :report
    end
    member do
      post :move_down
      post :move_up
      get :report
    end
  end
  resources :technique_links
  resources :user_images, only: [] do
    member do
      post :like
      patch :use
    end
  end
  resources :user_merge, only: %i[show update]
  resources :user_messages
  resources :users do
    member do
      post :change_password
      post :forgot_password
      patch :move_attribute
      get :photo
      patch :restore
      post :save_image
      get :valid
    end
  end

  resources :wazas

  draw_drilldown :member_drilldown
  draw_drilldown :user_drilldown

  root to: 'welcome#index'

  get 'documents/*path_info', controller: :documents, action: :webdav
end
