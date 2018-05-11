# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    return unless params[:q]
    @query = params[:q].strip

    if admin?
      member_users, @users = User.search(@query).to_a.partition(&:member)
      @former_members, @members = member_users.map(&:member).partition(&:left_on)
      @trials = NkfMemberTrial.search(@query).to_a
    end

    @pages = InformationPage
        .where('UPPER(title) LIKE ? OR UPPER(body) LIKE ?',
            *(["%#{UnicodeUtils.upcase(@query)}%"] * 2))
  end
end
