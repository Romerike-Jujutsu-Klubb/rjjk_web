# frozen_string_literal: true
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

  def expire_image(_attendance)
    cache_dir = ActionController::Base.page_cache_directory
    cached_files = Dir.glob(cache_dir + '/attendances/**/*')
    Rails.logger.info("Expire cached files: #{cached_files}")
    begin
      FileUtils.rm_f(cached_files)
    rescue Errno::ENOENT
      Rails.logger.warn("Cached files were removed before deletion: #{$!}")
    end
  end
end
