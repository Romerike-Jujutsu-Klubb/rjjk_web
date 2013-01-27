class WelcomeController < ApplicationController
  def index
    if user?
      redirect_to :controller => :news
      return
    end
    @information_page = InformationPage.find_by_title('Om klubben')
    render :template => 'info/show'
  end
  
end
