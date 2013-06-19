class SearchController < ApplicationController
  def index
    if params[:q]
      @query = params[:q]

      if admin?
        @members = Member.find_by_contents(@query).sort_by(&:name)
        @trials = NkfMemberTrial.
            where('UPPER(fornavn) LIKE ? OR UPPER(etternavn) LIKE ?',
                  *(["%#{UnicodeUtils.upcase(@query)}%"] * 2)).all
      end

      @pages = InformationPage.
          where('UPPER(title) LIKE ? OR UPPER(body) LIKE ?',
                *(["%#{UnicodeUtils.upcase(@query)}%"] * 2))
    end
  end
end
