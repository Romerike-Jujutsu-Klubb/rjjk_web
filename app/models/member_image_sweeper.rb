class MemberImageSweeper < ActionController::Caching::Sweeper
  observe MemberImage
  
  def after_create(member_image)
    expire_image(member_image)
  end
  
  def after_update(member_image)
    expire_image(member_image)
  end
  
  def after_destroy(member_image)
    expire_image(member_image)
  end
  
  private
  
  def expire_image(member_image)
    expire_page(:controller => 'members', :action => 'image',     :id => member_image.member_id, :format => member_image.format)
    expire_page(:controller => 'members', :action => 'thumbnail', :id => member_image.member_id, :format => member_image.format)
  end
  
end
