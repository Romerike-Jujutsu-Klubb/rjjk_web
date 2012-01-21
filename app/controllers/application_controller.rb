require 'user_system'

class ApplicationController < ActionController::Base
  protect_from_forgery
  include UserSystem
  include ActionController::Caching::Sweeping if defined?(JRUBY_VERSION)
  layout 'dark_ritual'
  helper :user

  before_filter :login_from_cookie
  before_filter :store_current_user_in_thread
  before_filter :load_layout_model
  live_tree :information_tree, :model => :information_page, :get_item_name_proc => Proc.new {|page| page.title}
  after_filter :clear_user

  private

  def load_layout_model
    @information_pages = InformationPage.roots
    if not admin?
      @information_pages = @information_pages.select{|ip| ip.visible?}
    end
    @events = Event.find(:all, :conditions => ['(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)', Date.today, Date.today], :order => 'start_at', :limit => 5)
  end

end
