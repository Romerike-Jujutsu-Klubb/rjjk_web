# frozen_string_literal: true

if Rails.env.development? || ENV['CACHE_STORE_LOGGER'] == 'ENABLED'
  ActiveSupport::Cache::Store.logger = Rails.logger.dup
  ActiveSupport::Cache::Store.logger.level = :debug
  ActiveSupport::Cache::Store.logger.debug 'Cache store logger enabled.'
end
