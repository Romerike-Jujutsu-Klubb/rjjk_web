class SearchController < ApplicationController
  def index
    if params[:q]
      @query = params[:q].strip

      if admin?
        @members = Member.search(@query).all
        @users = User.search(@query).all - @members.map(&:user)
        @trials = NkfMemberTrial.search(@query).all
      end

      @pages = InformationPage.
          where('UPPER(title) LIKE ? OR UPPER(body) LIKE ?',
                *(["%#{UnicodeUtils.upcase(@query)}%"] * 2))
    end
  end
end
