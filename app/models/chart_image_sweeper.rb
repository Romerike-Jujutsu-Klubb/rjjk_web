# frozen_string_literal: true

class ChartImageSweeper < ActionController::Caching::Sweeper
  observe :member, :user

  def after_create(_model)
    expire_image
  end

  def after_update(_model)
    expire_image
  end

  def after_destroy(_model)
    expire_image
  end

  private

  def expire_image
    cache_dir = ActionController::Base.page_cache_directory
    cached_files = Dir.glob("#{cache_dir}/members/**/{age_chart,history_graph}/**/*.png")
    Rails.logger.info("Expire cached files: #{cached_files}")
    begin
      FileUtils.rm_f(cached_files)
    rescue Errno::ENOENT => e
      Rails.logger.warn("Cached files were removed before deletion: #{e}")
    end
  end
end
