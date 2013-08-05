class AttendanceImageSweeper < ActionController::Caching::Sweeper
  observe Attendance

  def after_create(attendance)
    expire_image(attendance)
  end

  def after_update(attendance)
    expire_image(attendance)
  end

  def after_destroy(attendance)
    expire_image(attendance)
  end

  private

  def expire_image(attendance)
    [182, 800, 1024].each do |size|
      expire_page(:controller => 'attendances', :action => 'history_graph',
                  :format => :png, :id => size)
      expire_page(:controller => 'attendances', :action => 'month_chart',
                  :year => attendance.year, :month => attendance.date.month,
                  :size => size, :format => :png)
    end
  end

end
