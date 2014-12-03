Rails.application.routes.draw do
  match 'attendances/:action/:year/:week/:group_schedule_id/:status(/:member_id)',
      controller: :attendances, via: [:get, :post]
  get 'attendances/form/:year/:month/:group_id' => 'attendances#form'
  get ':controller/report(/:year/:month)', action: :report
  get 'info/versjon'
  get 'members/search'
  get 'members/grade_history_graph/:id(/:percentage/:step/:interval).:format' => 'members#grade_history_graph'
  get ':controller/history_graph/:id.:format', action: :history_graph
  get 'mitt/oppmote' => 'attendances#plan', as: :attendance_plan
  get 'attendances/plan' # må være etter mitt/oppmote
  post 'attendances/announce(/:year/:week/:group_schedule_id)/:status(/:member_id)' =>
          'attendances#announce'
  get 'news/list'
  get 'pensum' => 'ranks#pensum'
  get 'pensum/pdf' => 'ranks#pdf'
  get 'search/index'
  get 'user/change_password'
  post 'user/change_password'
  get 'user/forgot_password'
  post 'user/forgot_password'
  get 'user/login'
  post 'user/login'
  get 'user/logout'
  post 'user/signup'
  get 'user/welcome'

  get ':controller/month_per_year_chart/:month/:size.:format', action: :month_per_year_chart
  get ':controller/active_contracts', action: :active_contracts
  match ':controller/form', action: :form, via: [:get, :post]
  match ':controller/form/:id', action: :form, via: [:get, :post]
  match ':controller/form_index', action: :form_index, via: [:get, :post]
  get ':controller/calendar', action: :calendar
  post ':controller/create', action: :create
  get ':controller/email_list', action: :email_list
  get ':controller/excel_export', action: :excel_export
  get ':controller/gallery(/:id)', action: :gallery
  get ':controller/list_active', action: :list_active
  get ':controller/list_inactive', action: :list_active
  get ':controller/mine(/:id)', action: :mine
  get ':controller/telephone_list', action: :telephone_list
  get ':controller/yaml', action: :yaml

  resources :application_steps
  resources :appointments
  resources :annual_meetings
  resources :attendances
  resources :basic_technique_links
  resources :basic_techniques
  resources :birthday_celebrations
  resources :board_meetings
  resources :censors
  resources :cms_members
  resources :correspondences
  resources :elections
  resources :embus
  resources :embu_images
  resources :event_invitee_messages
  resources :event_invitees
  resources :event_messages
  resources :events
  #resources :events do
  #  get :calendar, :on => :collection
  #end
  resources :graduates
  resources :graduations
  resources :group_instructors
  resources :group_schedules
  resources :group_semesters
  resources :groups
  resources :images
  resources :information_pages, controller: :info, path: :info
  resources :martial_arts
  resources :members
  resources :news_items, controller: :news, path: :news
  resources :nkf_members
  resources :nkf_member_trials
  resources :page_aliases
  resources :practices
  resources :public_records
  resources :ranks
  resources :roles
  resources :semesters
  resources :signatures
  resources :technique_applications
  resources :trial_attendances
  resources :users, controller: :user, path: :user
  resources :wazas

  root to: 'welcome#index'
  get ':controller/service.wsdl', action: :wsdl
  get 'documents/*path_info', controller: :documents, action: :webdav

  get ':controller/:action/:year/:month/:size.:format'
  get ':controller/:action/:id/:width.:format'
  get ':controller/:action/:id/:width'
  get ':controller/:action/:id.:format'
  get ':controller/:action.:format'
  get ':controller/:action/:id'
  get ':controller/:action'
  get ':controller', action: :index
end
