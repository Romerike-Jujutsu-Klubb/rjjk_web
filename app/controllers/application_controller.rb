# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UserSystem

  DEFAULT_LAYOUT = 'dark_ritual'

  protect_from_forgery prepend: true, with: :exception

  layout DEFAULT_LAYOUT

  if Rails.env.production?
    before_action { redirect_to(host: 'www.jujutsu.no') if request.host != 'www.jujutsu.no' }
  end
  before_action :store_current_user_in_thread
  before_action :set_paper_trail_whodunnit
  before_action :set_locale

  if defined?(Rack::MiniProfiler) && (Rails.env.beta? || ENV['RACK_MINI_PROFILER'] == 'ENABLED')
    before_action { Rack::MiniProfiler.authorize_request if current_user.try(:admin?) }
  end

  # FIXME(uwe):  Set permitted params in each controller/action
  before_action { params.permit! }

  after_action :clear_user
  after_action do
    response.set_header('Origin-Trial', Rails.application.credentials.google_badge_origin_token)
  end

  NO_LAYOUT_KEYS = %i[partial text plain html body json].freeze
  def render(*args)
    if ((opts = args[0]).is_a?(Hash) &&
        (opts[:layout] == false || (opts.keys & NO_LAYOUT_KEYS).any?)) ||
          _layout(lookup_context, []) != DEFAULT_LAYOUT
      # Skip layout models
    else
      load_layout_model
    end
    super
  end

  private

  def load_layout_model
    unless @information_pages
      info_query = InformationPage.roots.order(:position)
      info_query = info_query.where('hidden IS NULL OR hidden = ?', false) unless admin?
      info_query = info_query.where('title <> ?', 'Velkommen') unless user?
      @information_pages = info_query.to_a
    end

    load_next_practices

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
          .includes(attending_invitees: %i[signup_confirmation user], declined_invitees: :user,
              event_invitees: %i[signup_confirmation invitation user])
          .where('(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)',
              Date.current, Date.current)
          .order('start_at, end_at').limit(5).to_a
      @layout_events += Graduation.includes(graduates: { member: :user }).where(group_notification: true)
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

  def load_next_practices
    return if @next_practices
    return unless (m = current_user&.member) && (groups = m.groups.select(&:planning)).any?

    @next_practices = groups.map(&:next_practice).sort_by(&:start_at)
  end

  def send_data(*)
    request.env['rack.session.options'][:skip] = true
    super
  end

  def set_locale
    if (locale_param = params.delete(:lang))
      case locale_param
      when 'nb', 'en'
        puts "Set session locale: #{locale_param.to_sym.inspect}" # rubocop: disable Rails/Output FIXME(uwe): Remove output
        session[:locale] = locale_param.to_sym
      when 'no'
        puts "Set 'no' session locale" # rubocop: disable Rails/Output FIXME(uwe): Remove output
        session[:locale] = :nb
      else
        puts 'Delete session locale' # rubocop: disable Rails/Output FIXME(uwe): Remove output
        session.delete(:locale)
      end
    end

    # FIXME(uwe): Remove
    if session[:locale]
      puts "Use session[:locale]: #{session[:locale].inspect}" # rubocop: disable Rails/Output
    elsif current_user&.locale
      puts "Use current_user.locale: #{current_user.locale.inspect}" # rubocop: disable Rails/Output
    elsif header_locale
      puts "Use header_locale: #{header_locale.inspect}" # rubocop: disable Rails/Output
    else
      puts "Use I18n.default_locale: #{I18n.default_locale}" # rubocop: disable Rails/Output
    end
    # EMXIF

    I18n.locale = session[:locale] || current_user&.locale || header_locale || I18n.default_locale
  end

  def header_locale
    header_locale = request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    case header_locale
    when 'nb', 'en'
      header_locale = header_locale.to_sym
    when 'no'
      header_locale = :nb
    else
      header_locale = nil
    end
    header_locale
  end

  def report_exception(ex)
    logger.warn ex
    logger.warn ex.backtrace.join($INPUT_RECORD_SEPARATOR)
    ExceptionNotifier.notify_exception(ex)
  end
end
