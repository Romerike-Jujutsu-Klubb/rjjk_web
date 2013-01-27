class GradeHistoryImageSweeper < ActionController::Caching::Sweeper
  observe Graduate
  
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
    expire_page(:controller => 'members', :action => 'grade_history_graph', :format => :png, :id => 182)
    expire_page(:controller => 'members', :action => 'grade_history_graph', :format => :png, :id => 800)
    expire_page(:controller => 'members', :action => 'grade_history_graph', :format => :png, :id => 1024)
    expire_page(:controller => 'members', :action => 'grade_history_graph_percentage', :format => :png, :id => 182)
    expire_page(:controller => 'members', :action => 'grade_history_graph_percentage', :format => :png, :id => 800)
    expire_page(:controller => 'members', :action => 'grade_history_graph_percentage', :format => :png, :id => 1024)
  end
  
end
