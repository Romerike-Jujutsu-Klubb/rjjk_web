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
        graduates = Graduate.includes(:graduation).references(:graduations)
            .where(member_id: current_user.member.id)
            .where.not(graduation_id: graduations.map(&:id))
            .where('graduations.held_on BETWEEN ? AND ?', Date.current, 1.month.from_now)
            .map { |c| GraduationNewsItem.new c.graduation }
        @news_items.concat graduates
        censors = Censor.includes(:graduation).references(:graduations)
            .where(member_id: current_user.member.id)
            .where.not(graduation_id: graduations.map(&:id))
            .where('graduations.held_on BETWEEN ? AND ?', Date.current, 1.month.from_now)
            .map { |c| GraduationNewsItem.new c.graduation }
        @news_items.concat censors
      end
      if load_next_practices
        now = Time.current
        @next_practices.each do |next_practice|
          @news_items << NewsItem.new(
              publish_at: now + (now - next_practice.start_at),
              body: render_to_string(
                  partial: 'layouts/next_practice',
                  locals: { next_practice: next_practice }
                )
            )
        end
      end
      event_query = Event.upcoming.order(:start_at)
      event_query = event_query.where.not(type: InstructorMeeting.name) unless current_user.instructor?
      event_query.each do |event|
        @news_items << NewsItem.new(publish_at: event.publish_at,
            body: render_to_string(partial: 'layouts/event_main', locals: {
              event: event,
              display_year: event.start_at.to_date.cwyear != Date.current.cwyear,
              display_month: true, display_times: true
            }))
      end
      @news_items.sort_by! { |n| n.publish_at || n.created_at }.reverse!
    else
      front_parallax
    end
  end

  def front_parallax
    load_front_page_content
    render 'front_parallax', layout: 'public'
  end

  private

  def load_front_page_content
    @front_page_sections = FrontPageSection.includes(:image).order(:position).to_a
    @event = Event.upcoming.order(:start_at).find { |e| current_user&.member || e.public? }
  end

  def graduation_body(graduations)
    table_rows = graduations.map do |g|
      weekday = helpers.day_name(g.held_on.wday)
      "|#{g.group.name}|#{weekday}|#{g.held_on}|kl. #{g.start_at.strftime('%R')}|"
    end
    "Følgende graderinger er satt opp dette semesteret:\n\n#{table_rows.join("\n")}"
  end
end
