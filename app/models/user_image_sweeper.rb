# frozen_string_literal: true

class UserImageSweeper < ActionController::Caching::Sweeper
  observe :user

  def after_create(user)
    expire_image(user)
  end

  def after_update(user)
    expire_image(user)
  end

  def after_destroy(user)
    expire_image(user)
  end

  private

  def expire_image(user)
    if user.profile_image
      ActionController::Base.expire_page(Rails.application.routes.url_for(
          only_path: true, controller: :users, action: :profile_image, id: user.id,
          format: user.profile_image.format
        ))
      ActionController::Base.expire_page(Rails.application.routes.url_for(
          only_path: true, controller: :users, action: :thumbnail, id: user.id,
          format: user.profile_image.format
        ))
    end
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
