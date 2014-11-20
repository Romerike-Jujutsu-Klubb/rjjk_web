class WelcomeController < ApplicationController
  def index
    if user?
      @news_items = NewsItem.front_page_items
      render template: 'news/index'
      return
    end
    if (@information_page = InformationPage.find_by_title('Velkommen'))
      render template: 'info/show'
    end
  end
end
