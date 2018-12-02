# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include UserSystem

  DEFAULT_LAYOUT = 'dark_ritual'

  protect_from_forgery prepend: true, with: :exception unless Rails.env.beta? # allow medusa login on beta

  layout DEFAULT_LAYOUT

  before_action :reject_bots
  before_action :store_current_user_in_thread

  if Rails.env.beta? && defined?(Rack::MiniProfiler)
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
      info_query = InformationPage.roots
      info_query = info_query.where('hidden IS NULL OR hidden = ?', false) unless admin?
      info_query = info_query.where('title <> ?', 'Velkommen') unless user?
      @information_pages = info_query.to_a
    end
    # unless @image
    #   3.times do
    #     Image.uncached do
    #       image_query = Image
    #           .select(%w[approved content_type description google_drive_reference height id name public
    #                      user_id width])
    #           .where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'")
    #           .order(Rails.env.test? ? :id : 'RANDOM()')
    #       image_query = image_query.where('approved = ?', true) unless admin?
    #       image_query = image_query.where('public = ?', true) unless user?
    #       @image = image_query.first
    #     end
    #     break unless @image
    #     @image.update_dimensions! unless @image.video?
    #     break
    #   rescue => e
    #     ExceptionNotifier.notify_exception(e)
    #   end
    # end

    if (m = current_user.try(:member)) && (group = m.groups.find(&:planning))
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
      group_query = Group.active(Date.current).order('to_age, from_age DESC')
      if admin?
        group_query =
            group_query.includes(:current_semester, group_schedules: { active_group_instructors: {
              member: [{ graduates: %i[graduation rank] }, :user],
            } })
      end
      @groups = group_query.to_a
    end

    unless @layout_events # rubocop: disable Style/GuardClause
      @layout_events = Event
          .where('(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)',
              Date.current, Date.current)
          .order('start_at, end_at').limit(5).to_a
      @layout_events += Graduation.includes(:graduates).where('held_on >= ?', Date.current).to_a
      @groups.select(&:school_breaks).each do |g|
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

  def report_exception(ex)
    logger.warn ex
    logger.warn ex.backtrace.join($INPUT_RECORD_SEPARATOR)
    ExceptionNotifier.notify_exception(ex)
  end
end
