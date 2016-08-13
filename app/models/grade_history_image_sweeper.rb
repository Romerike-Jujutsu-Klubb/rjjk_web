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
    cache_dir = ActionController::Base.page_cache_directory
    cached_files = Dir.glob(cache_dir + '/members/grade_history_graph*/**/*')
    Rails.logger.info("Expire cached files: #{cached_files}")
    FileUtils.rm_f(cached_files) rescue Errno::ENOENT
  end

end
