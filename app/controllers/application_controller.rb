# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UserSystem

  DEFAULT_LAYOUT = 'dark_ritual'

  protect_from_forgery with: :exception unless Rails.env.beta?

  layout DEFAULT_LAYOUT

  before_action :reject_bots
  before_action :store_current_user_in_thread

  if Rails.env.beta?
    before_action { Rack::MiniProfiler.authorize_request if current_user.try(:admin?) }
  end

  # FIXME(uwe):  Set permitted params in each controller/action
  before_action { params.permit! }

  after_action :clear_user

  def render(*args)
    load_layout_model unless args[0].is_a?(Hash) && args[0][:text] && !args[0][:layout]
    super
  end

  private

  def load_layout_model
    return if request.xhr? || _layout([]) != DEFAULT_LAYOUT
    unless @information_pages
      @information_pages = InformationPage.roots
      unless admin?
        @information_pages = @information_pages.where('hidden IS NULL OR hidden = ?', false)
      end
      @information_pages = @information_pages.where('title <> ?', 'Velkommen') unless user?
    end
    unless @image
      3.times do
        begin
          Image.uncached do
            image_query = Image
                .select(%w(approved content_type description height id name public user_id width))
                .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
                .order(Rails.env.test? ? :id : 'RANDOM()')
            image_query = image_query.where('approved = ?', true) unless admin?
            image_query = image_query.where('public = ?', true) unless user?
            @image = image_query.first
          end
          break unless @image
          @image.update_dimensions! unless @image.video?
          break
        rescue => e
          ExceptionNotifier.notify_exception(e)
        end
      end
    end

    if (m = current_user.try(:member)) && (group = m.groups.find { |g| g.name == 'Voksne' })
      @next_practice = group.next_practice
      @next_schedule = @next_practice.group_schedule
      attendances_next_practice = @next_practice.attendances.to_a
      @your_attendance_next_practice = attendances_next_practice.find { |a| a.member_id == m.id }
      attendances_next_practice.delete @your_attendance_next_practice
      @other_attendees = attendances_next_practice.select do |a|
        [Attendance::Status::WILL_ATTEND, Attendance::Status::ATTENDED]
            .include? a.status
      end
      @other_absentees = attendances_next_practice - @other_attendees
    end

    unless @groups
      @groups = Group.active(Date.current).order('to_age, from_age DESC')
          .includes(:current_semester, :next_semester).to_a
    end

    unless @layout_events # rubocop: disable Style/GuardClause
      @layout_events = Event.includes(:attending_invitees)
          .where('(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)',
              Date.current, Date.current)
          .order('start_at, end_at').limit(5).to_a
      @layout_events += Graduation.includes(:graduates)
          .where('held_on >= ?', Date.current).to_a
      @groups.select(&:school_breaks).each do |g|
        if (first_session = g.current_semester&.first_session) && first_session >= Date.current
          @layout_events << Event.new(name: "Oppstart #{g.name}",
              start_at: first_session)
        end
        if (last_date = g.current_semester&.last_session)
          @layout_events << Event.new(name: "Siste trening #{g.name}",
              start_at: last_date)
        end
        if (first_date = g.next_semester&.first_session)
          @layout_events << Event.new(name: "Oppstart #{g.name}",
              start_at: first_date)
        end
      end

      @layout_events.sort_by!(&:start_at)
    end
  end

  def reject_bots
    referrer = request.headers['HTTP_REFERER']
    if request.headers['HTTP_USER_AGENT'] =~ /BLEXBot/i || referrer =~ /baidu/i
      BotMailer.reject(request.headers).deliver_now
      if referrer.present?
        redirect_to referrer
      else
        render status: 429
      end
      false
    else
      true
    end
  end
end
