module ApplicationHelper
  include UserSystem
  
  def menu_item(name, options = {})
    options[:controller] ||= 'info'
    link_to name, {:controller => options[:controller], :action => options[:action], :id => options[:id]}, :class => [controller.controller_name, controller.action_name, params[:id].to_s] == [options[:controller].to_s, options[:action].to_s, options[:id].to_s] ? 'active' : nil
  end
    
  def yes_no(bool)    
    if bool == true
      "Ja"
    else
      "Nei"
    end
  end
  
  def t(time)
    return super if time.is_a?(Symbol) || time.is_a?(String)
    time && time.strftime('%H:%M')
  end
  
  def wday(wday_index)
    %w{Søndag Mandag Tirsdag Onsdag Torsdag Fredag Lørdag}[wday_index]
  end
  
end
