require 'user_system'

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  layout 'rjjk'
  include Localization
  include UserSystem
  helper :user
  model :user
  before_filter :load_layout_model
  live_tree :information_tree, :model => :information_page, :get_item_name_proc => Proc.new {|page| page.title}

  private
  
  def load_layout_model
    @news_items = NewsItem.find_all
    @information_pages = InformationPage.find_all
    @new_pages = InformationPage.find :all, :conditions => "created_at > '#{30.days.ago.iso8601}'"
    if InformationPage.count > 0
      @information_root = InformationPage.find(:first, :order => 'id')
    else
      @information_root = nil
    end
  end
  
end