ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/active_contracts', :action => 'active_contracts'
  map.connect ':controller/create', :action => 'create'
  map.connect ':controller/destroy', :action => 'destroy'
  map.connect ':controller/excel_export', :action => 'excel_export'
  map.connect ':controller/history_graph', :action => 'history_graph'
  map.connect ':controller/yaml', :action => 'yaml'

  map.resources :attendances
  map.resources :cms_members
  map.resources :events
  map.resources :group_schedules
  map.resources :groups
  map.resources :nkf_members
  map.resources :nkf_member_trials
  map.resources :trial_attendances

  map.connect '', :controller => "welcome"
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect 'documents/*path_info', :controller => 'documents', :action => 'webdav'

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
end
