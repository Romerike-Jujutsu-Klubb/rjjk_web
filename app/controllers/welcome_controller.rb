class WelcomeController < ApplicationController
  def index
    if user?
      @news_items = NewsItem.front_page_items
      render :template => 'news/index'
      return
    end
    @information_page = InformationPage.find_by_title('Velkommen')
    render :template => 'info/show' if @information_page
  end
end
