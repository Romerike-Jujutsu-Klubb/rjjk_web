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
    expire_page(:controller => 'attendances', :action => 'history_graph', :format => :png, :id => 182)
    expire_page(:controller => 'attendances', :action => 'history_graph', :format => :png, :id => 800)
    expire_page(:controller => 'attendances', :action => 'history_graph', :format => :png, :id => 1024)
  end
  
end
