RjjkWeb::Application.routes.draw do
  get 'info/versjon'
  get 'members/search'
  get 'mitt/oppmote' => 'attendances#plan'
  get 'attendances/plan' # må være etter mitt/oppmote
  get 'news/list'
  get 'search/index'

  match 'stylesheets/dark_ritual/:width.:format', controller: :stylesheets, action: :dark_ritual
  match 'stylesheets/dark_ritual.:format', controller: :stylesheets, action: :dark_ritual
  match ':controller/active_contracts', action: :active_contracts
  match ':controller/attendance_form', action: :attendance_form
  match ':controller/attendance_form_index', action: :attendance_form_index
  match ':controller/calendar', action: :calendar
  match ':controller/create', action: :create
  match ':controller/email_list', action: :email_list
  match ':controller/excel_export', action: :excel_export
  match ':controller/gallery/:id', action: :gallery
  match ':controller/gallery', action: :gallery
  match ':controller/list_active', action: :list_active
  match ':controller/list_inactive', action: :list_active
  match ':controller/telephone_list', action: :telephone_list
  match ':controller/mine', action: :mine
  match ':controller/yaml', action: :yaml

  resources :attendances
  resources :birthday_celebrations
  resources :cms_members
  resources :correspondences
  resources :embus
  resources :embu_images
  resources :event_invitee_messages
  resources :event_invitees
  resources :event_messages
  resources :events
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
  resources :semesters
  resources :trial_attendances

  root to: 'welcome#index'
  match ':controller/service.wsdl', action: :wsdl
  match 'documents/*path_info', controller: :documents, action: :webdav

  match ':controller/:action/:id/:width.:format'
  match ':controller/:action/:id/:width'
  match ':controller/:action/:id.:format'
  match ':controller/:action.:format'
  match ':controller/:action/:id'
  match ':controller/:action'
  match ':controller', action: :index
end
