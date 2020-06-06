# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @query = params[:q].presence
    return unless @query

    if admin?
      member_users, @users = User.search(@query).to_a.partition(&:last_membership)
      @deleted_users = User.only_deleted.search(@query).to_a
      @former_members, @members = member_users.map(&:last_membership).partition(&:left?)
      @trials = NkfMemberTrial.search(@query).to_a
      @user_messages = UserMessage.search(@query).to_a
    end

    query = "%#{@query.upcase.gsub(/(_|%)/, '\\\\\\1')}%"
    @pages = InformationPage
        .where('title ILIKE :query OR body ILIKE :query', query: query).order(:title).to_a
    news_items = NewsItem
        .where('title ILIKE :query OR summary ILIKE :query OR UPPER(body) LIKE :query', query: query)
        .order(created_at: :desc)
        .to_a
    @news = news_items.group_by { |n| n.created_at.year }
    @events = Event
        .where(%i[name name_en description description_en].map { |f| "#{f} ILIKE :query" }.join(' OR '),
            query: query)
        .order(start_at: :desc)
        .group_by { |e| e.start_at.year }
    @images = Image.where('UPPER(name) LIKE :query', query: query).order(:name).to_a
    @basic_techniques = BasicTechnique.includes(rank: { curriculum_group: :martial_art })
        .where('UPPER(basic_techniques.name) LIKE :query', query: query)
        .where(martial_arts: { original_martial_art_id: nil })
        .order(:name).to_a
    @technique_applications =
        TechniqueApplication.where('UPPER(name) LIKE :query', query: query).order(:name).to_a
  end
end
