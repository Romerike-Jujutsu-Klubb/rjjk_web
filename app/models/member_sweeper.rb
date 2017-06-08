# frozen_string_literal: true

class MemberSweeper < ActionController::Caching::Sweeper
  observe :member

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
      ActionController::Base.expire_page(Rails.application.routes.url_for(
          only_path: true, controller: 'members',
          action: 'image', id: member.id,
          format: member.image.format
      ))
      ActionController::Base.expire_page(Rails.application.routes.url_for(
          only_path: true, controller: 'members', action: 'thumbnail', id: member.id,
          format: member.image.format
      ))
    end
    cache_dir = ActionController::Base.page_cache_directory
    cached_files = Dir.glob(cache_dir + '/members/**/{age_chart,history_graph}/**/*')
    Rails.logger.info("Expire cached files: #{cached_files}")
    begin
      FileUtils.rm_f(cached_files)
    rescue Errno::ENOENT => e
      Rails.logger.warn("Cached files were removed before deletion: #{e}")
    end
  end
end
