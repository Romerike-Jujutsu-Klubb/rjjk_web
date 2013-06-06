RjjkWeb::Application.routes.draw do

  match 'stylesheets/dark_ritual/:width.:format', :controller => 'stylesheets', :action => 'dark_ritual'
  match 'stylesheets/dark_ritual.:format', :controller => 'stylesheets', :action => 'dark_ritual'
  match ':controller/active_contracts', :action => 'active_contracts'
  match ':controller/create', :action => 'create'
  match ':controller/excel_export', :action => 'excel_export'
  match ':controller/gallery/:id', :action => 'gallery'
  match ':controller/gallery', :action => 'gallery'
  match ':controller/mine', :action => 'mine'
  match ':controller/yaml', :action => 'yaml'
  match 'events/calendar', :controller => 'events', :action => 'calendar'

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
  resources :groups
  resources :images
  resources :martial_arts
  resources :news_items, :controller => 'news'
  resources :nkf_members
  resources :nkf_member_trials
  resources :semesters
  resources :trial_attendances

  root :to => 'welcome#index'
  match 'info/:id', :controller => :info, :action => :show
  match ':controller/service.wsdl', :action => 'wsdl'
  match 'documents/*path_info', :controller => 'documents', :action => 'webdav'

  match ':controller/:action/:id/:width.:format'
  match ':controller/:action/:id/:width'
  match ':controller/:action/:id.:format'
  match ':controller/:action.:format'
  match ':controller/:action/:id'
  match ':controller/:action'
  match ':controller', :action => 'index'
end
