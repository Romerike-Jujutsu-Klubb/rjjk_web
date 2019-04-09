# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    if user?
      @news_items = NewsItem.front_page_items
      if current_user.member
        graduations = Graduation
            .where(group_notification: true)
            .where('held_on BETWEEN ? AND ?', Date.current, 1.month.from_now)
            .order(:held_on).to_a
        if graduations.any?
          publish_at = 1.month.before(graduations.map(&:held_on).min)
          graduation_news = NewsItem.new(created_at: publish_at, title: 'Graderinger',
              body: graduation_body(graduations))
          @news_items.prepend graduation_news
        end
        events = Event
            .includes(:event_groups).references(:event_groups)
            .where('event_groups.group_id in (?)', current_user.member.groups.map(&:id))
            .where('start_at BETWEEN ? AND ?', Date.current, 1.month.from_now)
            .order(:start_at).to_a
        events.each do |event|
          publish_at = [event.created_at, 1.month.before(event.start_at)].max
          event_news = NewsItem.new(created_at: publish_at, title: event.name, body: event.description)
          @news_items.prepend event_news
        end
      end
      if load_next_practice
        @news_items << NewsItem.new(publish_at: @next_practice.start_at - 1.day,
            body: render_to_string(partial: 'layouts/next_practice'))
      end
      Event.upcoming.order(:start_at).each do |event|
        @news_items << NewsItem.new(publish_at: event.publish_at,
            body: render_to_string(partial: 'layouts/event_main', locals: {
              event: event,
              display_year: event.start_at.to_date.cwyear != Date.current.cwyear,
              display_month: true, display_times: true
            }))
      end
      @news_items.sort_by! { |n| n.publish_at || n.created_at }.reverse!
      render template: 'news/index'
      # return
    else
      front_page
      # return
    end
    # return unless (@information_page = InformationPage.find_by(title: 'Velkommen'))

    # render template: 'info/show'
  end

  # https://web.archive.org/web/20190203085358/https://www.altoros.com/
  def front_page
    @front_page_sections = FrontPageSection.all
    @event = Event.upcoming.order(:start_at).first
    @news_items = NewsItem.front_page_items.reject(&:expired?).first(5)
    render 'front_page', layout: 'public'
  end

  def front_parallax
    @front_page_sections = FrontPageSection.all
    @news_items = NewsItem.front_page_items.reject(&:expired?)
    render layout: 'parallax'
  end

  private

  def graduation_body(graduations)
    table_rows = graduations.map do |g|
      weekday = helpers.day_name(g.held_on.wday)
      "|#{g.group.name}|#{weekday}|#{g.held_on}|kl. #{g.start_at.strftime('%R')}|"
    end
    "Følgende graderinger er satt opp dette semesteret:\n\n#{table_rows.join("\n")}"
  end
end
