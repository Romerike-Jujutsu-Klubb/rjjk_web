# frozen_string_literal: true

Rack::MiniProfiler.config.enable_advanced_debugging_tools = true if ENV['RACK_MINI_PROFILER'] == 'ENABLED'
