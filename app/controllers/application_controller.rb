class ApplicationController < ActionController::Base
  DEFAULT_LAYOUT = 'dark_ritual'
  protect_from_forgery with: :exception
  include UserSystem
  # FIXME(uwe): Start using the new caching system
  include ActionController::Caching::Sweeping if defined?(JRUBY_VERSION)
  # EMXIF
  layout DEFAULT_LAYOUT
  helper :user

  before_filter :reject_baidu_bot
  before_filter :store_current_user_in_thread

  if Rails.env.beta?
    before_filter { Rack::MiniProfiler.authorize_request if current_user.try(:admin?) }
  end

  # FIXME(uwe):  Set permitted params in each controller/action
  before_filter { params.permit! }

  after_filter :clear_user

  def render(*args)
    load_layout_model unless args[0].is_a?(Hash) && args[0][:text] && !args[0][:layout]
    super
  end

  private

  def load_layout_model
    return if request.xhr? || _layout != DEFAULT_LAYOUT
    unless @information_pages
      @information_pages = InformationPage.roots
      @information_pages = @information_pages.where('hidden IS NULL OR hidden = ?', false) unless admin?
      @information_pages = @information_pages.where('title <> ?', 'Velkommen') unless user?
    end
    unless @image
      3.times do
        begin
          Image.uncached do
            image_query = Image.
                select('approved, content_type, description, height, id, name, public, user_id, width').
                where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'").
                order(Rails.env.test? ? :id : 'RANDOM()')
            image_query = image_query.where('approved = ?', true) unless admin?
            image_query = image_query.where('public = ?', true) unless user?
            @image = image_query.first
          end
          break unless @image
          @image.update_dimensions! unless @image.video?
          break
        rescue Exception
          ExceptionNotifier.notify_exception($!)
        end
      end
    end

    if (m = current_user.try(:member)) && (group = m.groups.find { |g| g.name == 'Voksne' })
      @next_practice = group.next_practice
      @next_schedule = @next_practice.group_schedule
      attendances_next_practice = @next_practice.attendances.to_a
      @your_attendance_next_practice = attendances_next_practice.find { |a| a.member_id == m.id }
      attendances_next_practice.delete @your_attendance_next_practice
      @other_attendees = attendances_next_practice.select { |a| [Attendance::Status::WILL_ATTEND, Attendance::Status::ATTENDED].include? a.status }
      @other_absentees = attendances_next_practice - @other_attendees
    end

    unless @layout_events
      @layout_events = Event.
          where('(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)', Date.today, Date.today).
          order('start_at, end_at').limit(5).to_a
      @layout_events += Graduation.where('held_on >= CURRENT_DATE').to_a
      @layout_events.sort_by!(&:start_at)
    end
    unless @groups
      @groups = Group.active(Date.today).order('to_age, from_age DESC').includes(:current_semester).to_a
    end
  end

  def reject_baidu_bot
    if request.headers['HTTP_REFERER'] =~ /baidu/i
      BaiduMailer.reject(request.headers['HTTP_REFERER']).deliver
      redirect_to request.headers['HTTP_REFERER']
      false
    else
      true
    end
  end

end
