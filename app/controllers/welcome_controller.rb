class WelcomeController < ApplicationController
  layout false, :action => :original
  
  def index
    redirect_to :controller => 'news'
  end
  
end
