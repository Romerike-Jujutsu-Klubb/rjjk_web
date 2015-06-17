source 'https://rubygems.org/'

gem 'rails', '~>4.2.1'

platform :jruby do
  gem 'activerecord-jdbc-adapter', github: 'jruby/activerecord-jdbc-adapter'
  gem 'activerecord-jdbcpostgresql-adapter', github: 'jruby/activerecord-jdbc-adapter'
end

platform :ruby do
  gem 'oily_png'
  gem 'pg'
end

gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
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
gem 'chosen-sass-bootstrap-rails', '>= 0.0.4'
gem 'coffee-rails'
gem 'draper' # https://github.com/drapergem/draper
gem 'dynamic_form'
gem 'exception_notification'
# gem 'fb_graph'
gem 'gmaps4rails', '<2.0.0' # TODO(uwe): switch to https://rubygems.org/gems/geocoder ?
gem 'gruff'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'mechanize'
gem 'momentjs-rails'
gem 'nokogiri'
gem 'nprogress-rails'
# gem 'paper_trail' # http://railscasts.com/episodes/255-undo-with-paper-trail?view=similar
gem 'prawn', '<2.0.0' # TODO(uwe): Upgrade?
gem 'prawn-table'
gem 'puma'
gem 'rails-i18n'
gem 'rails-observers', github: 'rails/rails-observers'
gem 'rake'
gem 'RedCloth'
gem 'red_cloth_formatters_plain'
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sass-rails', '>=4.0.5'
gem 'schema_plus'
gem 'simple_drilldown'
gem 'simple_workflow'
gem 'slim-rails'
gem 'therubyracer', platform: :ruby
gem 'therubyrhino', platform: :jruby
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
gem 'turbolinks'
gem 'uglifier'
gem 'unicode_utils'
gem 'will_paginate'

group :development do
  # gem 'bullet'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-scm-copy'
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
  gem 'vcr'
  gem 'webmock'
end

group :development, :beta do
  gem 'rack-mini-profiler'
end
