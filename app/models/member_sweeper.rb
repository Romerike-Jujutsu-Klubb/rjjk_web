class MemberSweeper < ActionController::Caching::Sweeper
  observe :Member
  
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
      ActionController::Base.expire_page(url_for(controller: 'members', action: 'image',     id: member.id, format: member.image.format))
      ActionController::Base.expire_page(url_for(controller: 'members', action: 'thumbnail', id: member.id, format: member.image.format))
    end
    cache_dir = ActionController::Base.page_cache_directory
    cached_files = Dir.glob(cache_dir + '/members/{age_chart,history_graph}/**/*')
    Rails.logger.info("Expire cached files: #{cached_files}")
    FileUtils.rm_f(cached_files) rescue Errno::ENOENT
  end
  
end
