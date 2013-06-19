class SearchController < ApplicationController
  def index
    if params[:q]
      @query = params[:q]

      @members = Member.find_by_contents(@query)
      @members = @members.sort_by { |member| member.last_name }

      @pages = InformationPage.where("UPPER(title) LIKE ? OR UPPER(body) LIKE ?", *(["%#{UnicodeUtils.upcase(@query)}%"] * 2))
    end
  end
end
