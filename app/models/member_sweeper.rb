class MemberSweeper < ActionController::Caching::Sweeper
  observe Member
  
  def after_create(member)
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
    if member.image
      expire_page(:controller => 'members', :action => 'image',     :id => member.id, :format => member.image.format)
      expire_page(:controller => 'members', :action => 'thumbnail', :id => member.id, :format => member.image.format)
    end
    expire_page(:controller => 'members', :action => 'history_graph', :format => :png, :id => 182)
    expire_page(:controller => 'members', :action => 'history_graph', :format => :png, :id => 1024)
  end
  
end
