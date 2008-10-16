class ImageSweeper < ActionController::Caching::Sweeper
  observe Image
  
  def after_update(image)
    expire_image(image)
  end
  
  def after_destroy(image)
    expire_image(image)
  end
  
  private
  
  def expire_image(image)
    expire_page(:controller => 'images', :action => 'show', :id => image.id, :format => image.format)
    expire_page(:controller => 'images', :action => 'inline', :id => image.id, :format => image.format)
  end
  
end
