# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    if user?
      @news_items = NewsItem.front_page_items
      graduations = Graduation
          .where(group_notification: true)
          .where('held_on BETWEEN ? AND ?', Date.current, 1.month.from_now)
          .order(:held_on).to_a
      if graduations.any?
        publish_at = 1.month.before(graduations.map(&:held_on).min)
        graduation_news =
            NewsItem.new(created_at: publish_at, title: 'Graderinger', body: graduation_body(graduations))
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
      @news_items.sort_by! { |n| n.publish_at || n.created_at }.reverse!
      render template: 'news/index'
      return
    end
    return unless (@information_page = InformationPage.find_by(title: 'Velkommen'))

    render template: 'info/show'
  end

  private

  def graduation_body(graduations)
    table_rows = graduations.map do |g|
      weekday = t(:date)[:day_names][g.held_on.wday]
      "|#{g.group.name}|#{weekday}|#{g.held_on}|kl. #{g.start_at.strftime('%R')}|"
    end
    "Følgende graderinger er satt opp dette semesteret:\n\n#{table_rows.join("\n")}"
  end
end
