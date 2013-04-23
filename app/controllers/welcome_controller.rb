class WelcomeController < ApplicationController
  def index
    if user?
      redirect_to :controller => :news
      return
    end
    @information_page = InformationPage.find_by_title('Velkommen')
    render :template => 'info/show' if @information_page
  end
  
end
