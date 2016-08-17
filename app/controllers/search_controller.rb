# frozen_string_literal: true
class SearchController < ApplicationController
  def index
    if params[:q]
      @query = params[:q].strip

      if admin?
        @members = Member.search(@query).to_a
        @users = User.search(@query).to_a - @members.map(&:user)
        @trials = NkfMemberTrial.search(@query).to_a
      end

      @pages = InformationPage
          .where('UPPER(title) LIKE ? OR UPPER(body) LIKE ?',
                *(["%#{UnicodeUtils.upcase(@query)}%"] * 2))
    end
  end
end
