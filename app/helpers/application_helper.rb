# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization
  include UserSystem
  
  def menu_item(name, action, id = nil)
    link_to name, {:controller => 'info', :action => action, :id => id}, :class => [controller.controller_name, controller.action_name] == ['info', action.to_s] ? 'active' : nil
  end

end
