# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization
  def user?
    !@session['user'].nil?
  end
end
