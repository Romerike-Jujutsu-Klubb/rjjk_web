# frozen_string_literal: true
source 'https://rubygems.org/'

gem 'rails', '~>4.2.1'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'therubyrhino'
end

platform :ruby do
  gem 'oily_png'
  gem 'pg'
  gem 'therubyracer'
end

gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
gem 'activerecord-time'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'bcrypt'
# gem 'bootstrap', github: 'twbs/bootstrap-rubygem' # TODO(uwe): Move to Bootstrap 4?
gem 'bootstrap-sass', '!=3.3.5'
gem 'bootstrap3-datetimepicker-rails'
gem 'bootstrap_form'
# gem "bootstrap-select-rails"
# gem "bootstrap-switch-rails"
# gem "bootstrap-wysihtml5-rails"
gem 'chosen-rails'
gem 'chosen-sass-bootstrap-rails'
gem 'coffee-rails'
gem 'draper' # https://github.com/drapergem/draper
gem 'dynamic_form'
gem 'exception_notification'
# gem 'fb_graph'
gem 'font-awesome-rails'
gem 'gmaps4rails', '<2.0.0' # TODO(uwe): switch to https://rubygems.org/gems/geocoder ?
gem 'gruff'
gem 'jbuilder'
gem 'jquery-rails'
# gem 'jquery-turbolinks'
gem 'kramdown'
gem 'lazyload-rails'
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
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sass-rails', '>=4.0.5'
gem 'schema_plus'

# FIXME(uwe): https://github.com/sparklemotion/nokogiri/issues/1382
# FIXME(uwe): https://github.com/sparklemotion/nokogiri/pull/1478
gem 'script_relocator', github: 'donv/script_relocator', platform: :ruby
# EMXIF

gem 'simple_drilldown'
gem 'simple_workflow'
gem 'slim-rails'
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
# FIXME(uwe): https://github.com/kossnocorp/jquery.turbolinks/pull/58
# gem 'turbolinks', '<5'
# EMXIF
gem 'uglifier'
gem 'unicode_utils'
gem 'will_paginate'

group :beta, :email, :production do
  gem 'lograge'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-scm-copy'
end

group :test do
  gem 'capybara-screenshot-diff', github: 'donv/capybara-screenshot-diff'
  gem 'chunky_png'
  gem 'database_cleaner'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'mocha', require: 'mocha/setup'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rubocop'
  # gem 'rubycritic', require: false
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :development, :beta do
  gem 'medusa', github: 'donv/medusa', branch: 'patch-1'
  gem 'rack-mini-profiler'
end
