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
    ApplicationController.expire_page(Rails.application.routes.url_for(controller: :images, action: :show, id: image.id, format: image.format, only_path: true))
    ApplicationController.expire_page(Rails.application.routes.url_for(controller: :images, action: :inline, id: image.id, format: image.format, only_path: true))
  end
  
end
