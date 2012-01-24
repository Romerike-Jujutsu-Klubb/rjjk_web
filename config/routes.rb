RjjkWeb::Application.routes.draw do
  match 'news' => 'news#index'
  match 'stylesheets/dark_ritual/:width.:format', :controller => 'stylesheets', :action => 'dark_ritual'
  match 'stylesheets/dark_ritual.:format', :controller => 'stylesheets', :action => 'dark_ritual'
  match ':controller', :action => 'index'
  match ':controller/active_contracts', :action => 'active_contracts'
  match ':controller/create', :action => 'create'
  match ':controller/destroy', :action => 'destroy'
  match ':controller/excel_export', :action => 'excel_export'
  match ':controller/yaml', :action => 'yaml'

  resources :attendances
  resources :cms_members
  resources :events
  resources :group_schedules
  resources :groups
  resources :nkf_members
  resources :nkf_member_trials
  resources :trial_attendances

  root :to => "welcome#index"
  match ':controller/service.wsdl', :action => 'wsdl'
  match 'documents/*path_info', :controller => 'documents', :action => 'webdav'

  match ':controller/:action/:id.:format'
  match ':controller/:action.:format'
  match ':controller/:action/:id'
  match ':controller/:action'
end
