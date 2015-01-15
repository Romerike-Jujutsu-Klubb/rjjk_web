# http://torquebox.org/4x/builds/
# http://torquebox.org/4x/builds/LATEST/docs/TorqueBox/Scheduling/Scheduler.html#schedule-class_method
# https://github.com/tmm1/rblineprof
# https://github.com/tmm1/stackprof
# source 'http://torquebox.org/4x/builds/gem-repo/'
# gem 'torquebox-web', '>=4.x.incremental.173'

source 'https://rubygems.org/'

gem 'rails', '< 4.2.0'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
end

platform :ruby do
  gem 'pg'
end

gem 'actionpack-page_caching'
gem 'activerecord-time'
gem 'acts_as_list'
gem 'acts_as_tree'
# gem 'bcrypt', '~> 3.1.7'
gem 'bootstrap-sass'
gem 'bootstrap3-datetimepicker-rails'
# gem "bootstrap-switch-rails"
# gem "bootstrap-wysihtml5-rails"
# gem "bootstrap-select-rails"
gem 'chosen-rails'
gem 'chosen-sass-bootstrap-rails'
gem 'coffee-rails'
gem 'colorbox-rails'
gem 'draper' # https://github.com/drapergem/draper
gem 'dynamic_form'
gem 'exception_notification'
# gem 'fb_graph'
gem 'gmaps4rails', '<2.0.0'
gem 'gruff'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'mechanize'
gem 'momentjs-rails'
gem 'nokogiri'
gem 'nprogress-rails'
# gem 'paper_trail' # http://railscasts.com/episodes/255-undo-with-paper-trail?view=similar
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'rails-i18n'
gem 'rails-observers'
gem 'rake'
gem 'RedCloth'
gem 'red_cloth_formatters_plain'
gem 'redbox', '~> 1.0.4'
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sass-rails', '>=4.0.5'
gem 'schema_plus'
gem 'simple_drilldown'
gem 'simple_workflow'
gem 'therubyrhino'
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
gem 'turbolinks'
gem 'uglifier'
gem 'unicode_utils'
gem 'will_paginate'

group :development do
  # gem 'bullet'
  gem 'capistrano', '<3.0.0'
  gem 'rvm-capistrano'
end

group :test do
  gem 'chunky_png'
  gem 'database_cleaner'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'mocha', require: 'mocha/setup'
  gem 'poltergeist'
  gem 'rubycritic', require: false
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'timecop'
end

group :development, :beta do
  gem 'rack-mini-profiler'
end
