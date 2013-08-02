class SearchController < ApplicationController
  def index
    if params[:q]
      @query = params[:q].strip

      if admin?
        @members = Member.find_by_contents(@query)
        @users = User.find_by_contents(@query) - @members.map(&:user)
        @trials = NkfMemberTrial.find_by_contents(@query)
      end

      @pages = InformationPage.
          where('UPPER(title) LIKE ? OR UPPER(body) LIKE ?',
                *(["%#{UnicodeUtils.upcase(@query)}%"] * 2))
    end
  end
end
