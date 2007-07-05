# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization
  def user?
    !session['user'].nil?
  end
  
  def menu_item(name, action, id = nil)
    link_to name, {:controller => 'info', :action => action, :id => id}, :class => [controller.controller_name, controller.action_name] == ['info', action.to_s] ? 'active' : nil
  end

end
