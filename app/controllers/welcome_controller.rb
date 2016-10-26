# frozen_string_literal: true
class WelcomeController < ApplicationController
  def index
    if user?
      @news_items = NewsItem.front_page_items
      render template: 'news/index'
      return
    end
    return unless (@information_page = InformationPage.find_by(title: 'Velkommen'))
    render template: 'info/show'
  end
end
