require 'user_system'

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_rjjk_web_session_id'
  layout 'zenlike'
  include Localization
  include UserSystem
  helper :user
  before_filter :load_layout_model
  live_tree :information_tree, :model => :information_page, :get_item_name_proc => Proc.new {|page| page.title}

  private
  
  def load_layout_model
    @information_pages = InformationPage.roots
  end
  
end