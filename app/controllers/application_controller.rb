# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UserSystem

  DEFAULT_LAYOUT = 'dark_ritual'

  protect_from_forgery prepend: true, with: :exception

  layout DEFAULT_LAYOUT

  if Rails.env.production?
    before_action { redirect_to(host: 'jujutsu.no') if request.host != 'jujutsu.no' }
  end
  before_action :reject_bots
  before_action :store_current_user_in_thread
  before_action :set_paper_trail_whodunnit
  before_action :set_locale

  if defined?(Rack::MiniProfiler) && (Rails.env.beta? || ENV['RACK_MINI_PROFILER'] == 'ENABLED')
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
      info_query = InformationPage.roots.order(:position)
      info_query = info_query.where('hidden IS NULL OR hidden = ?', false) unless admin?
      info_query = info_query.where('title <> ?', 'Velkommen') unless user?
      @information_pages = info_query.to_a
    end

    load_next_practice

    group_query = Group.active(Date.current).order('to_age, from_age DESC')
    if admin?
      group_query =
          group_query.includes(:current_semester, group_schedules: { active_group_instructors: {
            member: [{ graduates: %i[graduation rank] }, :user],
          } })
    end
    @layout_groups = group_query.to_a

    unless @layout_events # rubocop: disable Style/GuardClause
      @layout_events = Event
          .where('(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)',
              Date.current, Date.current)
          .order('start_at, end_at').limit(5).to_a
      @layout_events += Graduation.includes(:graduates).where(group_notification: true)
          .where('held_on >= ?', Date.current).to_a
      @layout_groups.select(&:school_breaks).each do |g|
        if (first_session = g.current_semester&.first_session) && first_session >= Date.current
          @layout_events << Event.new(name: "Oppstart #{g.name}", start_at: first_session)
        end
        if (last_date = g.current_semester&.last_session)
          @layout_events << Event.new(name: "Siste trening #{g.name}", start_at: last_date)
        end
        if (first_date = g.next_semester&.first_session)
          @layout_events << Event.new(name: "Oppstart #{g.name}", start_at: first_date)
        end
      end

      @layout_events.sort_by!(&:start_at)
    end
  end

  def load_next_practice
    return if @next_practice
    return unless (m = current_user&.member) && (group = m.groups.find(&:planning))

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
    @next_practice
  end

  def send_data(*)
    request.env['rack.session.options'][:skip] = true
    super
  end

  def reject_bots
    http_headers = request.headers.to_h.select { |k, _v| /^[A-Z0-9_]+$/ =~ k }
    referrer = http_headers['HTTP_REFERER']
    if http_headers['HTTP_USER_AGENT'] =~ /BLEXBot/i || referrer =~ /baidu/i
      BotMailer.reject(http_headers).deliver_now
      if referrer.present?
        redirect_to referrer
      else
        render status: :too_many_requests
      end
      false
    else
      true
    end
  end

  def set_locale
    if (locale_param = params.delete(:lang))
      case locale_param
      when 'nb', 'en'
        session[:locale] = locale_param.to_sym
      when 'no'
        session[:locale] = :nb
      else
        session.delete(:locale)
      end
    end
    header_locale = request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    case header_locale
    when 'nb', 'en'
      header_locale = header_locale.to_sym
    when 'no'
      header_locale = :nb
    else
      header_locale = nil
    end
    I18n.locale = session[:locale] || header_locale || I18n.default_locale
  end

  def report_exception(ex)
    logger.warn ex
    logger.warn ex.backtrace.join($INPUT_RECORD_SEPARATOR)
    ExceptionNotifier.notify_exception(ex)
  end
end
