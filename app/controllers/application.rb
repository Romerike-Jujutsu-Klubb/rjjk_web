require 'user_system'

class ApplicationController < ActionController::Base
  include Localization
  include UserSystem
  session :session_key => '_rjjk_web_session_id'
  # layout 'zenlike'
  layout 'dark_ritual'
  helper :user

  before_filter :login_from_cookie
  before_filter :load_layout_model
  live_tree :information_tree, :model => :information_page, :get_item_name_proc => Proc.new {|page| page.title}

  private
  
  def load_layout_model
    @information_pages = InformationPage.roots
    @events = Event.find(:all, :conditions => ['end_at >= ?', Time.now], :order => 'start_at', :limit => 5)
  end
  
end