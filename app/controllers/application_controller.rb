class ApplicationController < ActionController::Base
  DEFAULT_LAYOUT = 'dark_ritual'
  protect_from_forgery
  include UserSystem
  include ActionController::Caching::Sweeping if defined?(JRUBY_VERSION)
  layout DEFAULT_LAYOUT
  helper :user

  before_filter :store_current_user_in_thread
  after_filter :clear_user

  def render(*args)
    load_layout_model unless args[0].is_a?(Hash) && args[0][:text] && !args[0][:layout]
    super
  end

  private

  def load_layout_model
    return unless _layout == DEFAULT_LAYOUT
    unless @information_pages
      @information_pages = InformationPage.roots
      @information_pages = @information_pages.where('hidden IS NULL OR hidden = ?', false) unless admin?
      @information_pages = @information_pages.where('title <> ?', 'Velkommen') unless user?
    end
    unless @image
      loop do
        begin
          Image.uncached do
            image_query = Image.
                select('approved, content_type, description, height, id, name, public, user_id, width').
                where("content_type LIKE 'image/%' OR content_type LIKE 'video/%'").
                order('RANDOM()')
            image_query = image_query.where('approved = ?', true) unless admin?
            image_query = image_query.where('public = ?', true) unless user?
            @image = image_query.first
          end
          @image.update_dimensions! unless @image.video?
          break
        rescue Exception
          ExceptionNotifier.notify_exception($!)
          retry
        end
      end
    end
    @new_image = Image.new if user? # For uploading a new image.

    if (m = current_user.try(:member)) && (group = m.groups.find { |g| g.name == 'Voksne' })
      @next_practice = group.next_practice
      @next_schedule = group.next_schedule
      attendances_next_practice = Attendance.
          where('group_schedule_id = ? AND year = ? AND week = ?',
                @next_schedule.id, @next_practice.cwyear, @next_practice.cweek).
          all
      @your_attendance_next_practice = attendances_next_practice.find { |a| a.member_id == m.id }
      attendances_next_practice.delete @your_attendance_next_practice
      @other_attendees = attendances_next_practice.select { |a| [Attendance::WILL_ATTEND, Attendance::ATTENDED].include? a.status }
      @other_absentees = attendances_next_practice - @other_attendees
    end

    unless @events
      @events = Event.
          where('(end_at IS NULL AND start_at >= ?) OR (end_at IS NOT NULL AND end_at >= ?)', Date.today, Date.today).
          order('start_at, end_at').limit(5).all
    end
    unless @groups
      @groups = Group.active(Date.today).order('to_age, from_age DESC').includes(:current_semester).all
    end
  end

end
