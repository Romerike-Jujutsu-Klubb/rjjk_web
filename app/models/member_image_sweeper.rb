class MemberImageSweeper < ActionController::Caching::Sweeper
  observe Member
  
  def after_create(member)
    5.times{puts '*' * 80}
    expire_image(member)
  end
  
  def after_update(member)
    expire_image(member)
  end
  
  def after_destroy(member)
    expire_image(member)
  end
  
  private
  
  def expire_image(member)
    expire_page(:controller => 'members', :action => 'image', :id => member.id, :format => member.image_format)
    expire_page(:controller => 'members', :action => 'image_thumbnail', :id => member.id, :format => member.image_format)
    expire_page(:controller => 'members', :action => 'history_graph', :format => :png, :id => 182)
    expire_page(:controller => 'members', :action => 'history_graph', :format => :png, :id => 1024)
  end
  
end
