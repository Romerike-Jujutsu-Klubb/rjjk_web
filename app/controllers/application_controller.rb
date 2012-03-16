class ApplicationController < ActionController::Base
  protect_from_forgery
  include UserSystem
  include ActionController::Caching::Sweeping if defined?(JRUBY_VERSION)
  layout 'dark_ritual'
  helper :user

  before_filter :login_from_cookie
  before_filter :store_current_user_in_thread
  before_filter :load_layout_model
  after_filter :clear_user

  private

  def load_layout_model
    @information_pages = InformationPage.roots
    if not admin?
      @information_pages = @information_pages.select{|ip| ip.visible?}
    end
    image_query = Image.select('content_type, description, id, name').where("content_type LIKE 'image/%%' OR content_type LIKE 'video/%%'", true).order('RANDOM()')
    image_query = image_query.where('public = ? AND approved = ?', true, true) unless admin?
    @image = image_query.first
    @new_image = Image.new
    @events = Event.all(:conditions => ['(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)', Date.today, Date.today], :order => 'start_at', :limit => 5)
  end

end
