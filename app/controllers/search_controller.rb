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

    query = "%#{UnicodeUtils.upcase(@query).gsub(/(_|%)/, '\\\\\\1')}%"
    @pages = InformationPage
        .where('UPPER(title) LIKE :query OR UPPER(body) LIKE :query', query: query).order(:title).to_a
    news_items = NewsItem
        .where('UPPER(title) LIKE :query OR UPPER(summary) LIKE :query OR UPPER(body) LIKE :query',
            query: query)
        .order(created_at: :desc)
        .to_a
    @news = news_items.group_by { |n| n.created_at.year }
    @images = Image.where('UPPER(name) LIKE :query', query: query).order(:name).to_a
  end
end
