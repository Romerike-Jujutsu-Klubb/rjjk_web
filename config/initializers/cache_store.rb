# frozen_string_literal: true

if ENV['LOG_CACHE_STORE'] || Rails.env.development?
  ActiveSupport::Cache::Store.logger = Rails.logger
end
