# http://torquebox.org/4x/builds/
# http://torquebox.org/4x/builds/LATEST/docs/TorqueBox/Scheduling/Scheduler.html#schedule-class_method
# https://github.com/tmm1/rblineprof
# https://github.com/tmm1/stackprof

source 'https://rubygems.org/'
source 'http://torquebox.org/4x/builds/gem-repo/'

gem 'rails'

# gem 'activerecord-jdbc-adapter'
gem 'activerecord-jdbcpostgresql-adapter'
gem 'activerecord-time'
gem 'acts_as_list'
gem 'acts_as_tree'
# gem 'bcrypt', '~> 3.1.7'

# FIXME(uwe):  Only needed for prerelease
# gem 'arel', git: 'https://github.com/rails/arel'
# EMXIF

gem 'bootstrap3-datetimepicker-rails' # , git: 'https://github.com/TrevorS/bootstrap3-datetimepicker-rails'
gem 'colorbox-rails'
gem 'draper' # https://github.com/drapergem/draper
gem 'dynamic_form'
gem 'exception_notification'
# gem 'fb_graph'
gem 'gmaps4rails', '<2.0.0'
gem 'gruff'

# FIXME(uwe): Only needed for prerelease
# gem 'i18n', git: 'https://github.com/svenfuchs/i18n'
# EMXIF

gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mechanize'
gem 'momentjs-rails'
gem 'nokogiri'
# gem 'paper_trail' # http://railscasts.com/episodes/255-undo-with-paper-trail?view=similar
gem 'prawn'
gem 'puma'
gem 'rails-i18n'

# FIXME(uwe):  Only needed for prerelease
# gem 'rack', git: 'https://github.com/rack/rack'
# EMXIF

gem 'rake'
gem 'RedCloth'
gem 'red_cloth_formatters_plain'
gem 'redbox', '~> 1.0.4'
gem 'ri_cal'
gem 'rmagick4j'
gem 'rufus-scheduler'
# gem 'schema_plus'
gem 'sdoc', '~> 0.4.0',                              group: :doc
gem 'simple_drilldown'
gem 'simple_workflow'
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
# gem 'torquebox-web', '>=4.x.incremental.173'
gem 'turbolinks'
gem 'unicode_utils'
gem 'will_paginate'

# group :assets do
  gem 'bootstrap-sass'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'sass-rails', '~> 4.0.3'
  gem 'therubyrhino'
  # gem 'turbo-sprockets-rails3'
  gem 'uglifier', '>= 1.3.0'
# end

group :development do
  gem 'rdoc'
  # gem 'capistrano', '<3.0.0'
  gem 'capistrano-rails', group: :development
end

group :test do
  gem 'minitest-rails-capybara'
  gem 'chunky_png'
  gem 'database_cleaner'
  gem 'minitest-reporters'
  gem 'mocha', :require => 'mocha/setup'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'timecop'
end

group :development, :beta do
  gem 'rack-mini-profiler'
end
