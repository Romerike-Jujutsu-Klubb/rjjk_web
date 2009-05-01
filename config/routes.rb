ActionController::Routing::Routes.draw do |map|
  map.resources :nkf_members

  map.connect ':controller/active_contracts', :action => 'active_contracts'
  map.connect ':controller/create', :action => 'create'
  map.connect ':controller/destroy', :action => 'destroy'
  map.connect ':controller/excel_export', :action => 'excel_export'
  map.connect ':controller/history_graph', :action => 'history_graph'

  map.resources :cms_members
  map.resources :attendances
  map.resources :events
  map.resources :group_schedules
  map.resources :groups

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect 'documents/*path_info', :controller => 'documents', :action => 'webdav'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'
end
