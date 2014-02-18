RjjkWeb::Application.routes.draw do
  get 'attendances/review/:practice_id' => 'attendances#review'
  get 'attendances/form/:year/:month/:group_id' => 'attendances#form'
  get ':controller/report(/:year/:month)' => '#report'
  get 'info/versjon'
  get 'members/search'
  get 'mitt/oppmote' => 'attendances#plan'
  get 'attendances/plan' # må være etter mitt/oppmote
  get 'news/list'
  get 'search/index'
  get 'user/change_password'
  get 'user/forgot_password'
  get 'user/login'
  get 'user/logout'
  get 'user/welcome'

  match ':controller/month_per_year_chart/:month/:size.:format', action: :month_per_year_chart
  match ':controller/active_contracts', action: :active_contracts
  match ':controller/form', action: :form
  match ':controller/form/:id', action: :form
  match ':controller/form_index', action: :form_index
  match ':controller/calendar', action: :calendar
  match ':controller/create', action: :create
  match ':controller/email_list', action: :email_list
  match ':controller/excel_export', action: :excel_export
  match ':controller/gallery(/:id)', action: :gallery
  match ':controller/list_active', action: :list_active
  match ':controller/list_inactive', action: :list_active
  match ':controller/mine(/:id)', action: :mine
  match ':controller/telephone_list', action: :telephone_list
  match ':controller/yaml', action: :yaml

  resources :annual_meetings
  resources :attendances
  resources :birthday_celebrations
  resources :censors
  resources :cms_members
  resources :correspondences
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
  resources :semesters
  resources :signatures
  resources :trial_attendances
  resources :users, controller: :user, path: :user

  root to: 'welcome#index'
  match ':controller/service.wsdl', action: :wsdl
  match 'documents/*path_info', controller: :documents, action: :webdav

  match ':controller/:action/:year/:month/:size.:format'
  match ':controller/:action/:id/:width.:format'
  match ':controller/:action/:id/:width'
  match ':controller/:action/:id.:format'
  match ':controller/:action.:format'
  match ':controller/:action/:id'
  match ':controller/:action'
  match ':controller', action: :index
end
