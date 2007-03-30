class WelcomeController < ApplicationController
  def index
    redirect_to :controller => 'news'
  end
  
end
