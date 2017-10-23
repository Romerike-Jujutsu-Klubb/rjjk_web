# frozen_string_literal: true

source 'https://rubygems.org/'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~>5.1.4'

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', github: 'jruby/activerecord-jdbc-adapter',
      branch: 'rails-5'
  gem 'therubyrhino'
end

platform :ruby do
  gem 'oily_png'
  gem 'pg'
  gem 'therubyracer'
end

gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
gem 'activerecord-time'
gem 'acts_as_list' # https://github.com/swanandp/acts_as_list/pull/283
gem 'acts_as_tree'
gem 'bcrypt'
gem 'bootstrap'
gem 'bootstrap-chosen-rails', github: 'donv/bootstrap-chosen-rails'
gem 'bootstrap3-datetimepicker-rails'
gem 'bootstrap_form', github: 'bootstrap-ruby/rails-bootstrap-forms', branch: 'bootstrap-v4'
# https://mdbootstrap.com/javascript/sidenav/
# https://github.com/flatlogic/awesome-bootstrap-checkbox
# gem "bootstrap-select-rails"
# gem "bootstrap-switch-rails"
# gem "bootstrap-wysihtml5-rails"
gem 'capistrano3-puma'
gem 'chartkick'
gem 'chosen-rails'
gem 'coffee-rails'
gem 'dynamic_form'
gem 'exception_notification'
# gem 'fb_graph'
gem 'font-awesome-rails'
gem 'geocoder'
gem 'gruff'
# gem 'jasny-bootstrap-rails'
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
gem 'prawn'
# gem 'prawn-gmagick'
gem 'prawn-table'
gem 'puma'
gem 'rack-attack'
gem 'rails-assets-tether'
gem 'rails-controller-testing' # Remove and convert to IntergratonTest instead
gem 'rails-i18n'
gem 'rails-observers', github: 'rails/rails-observers'
gem 'rails_autolink'
gem 'rake'
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sass-rails'
gem 'schema_auto_foreign_keys'

# FIXME(uwe): Remove this line when there is a stable release supporting AR 5.1
gem 'schema_plus_foreign_keys', github: 'SchemaPlus/schema_plus_foreign_keys',
    branch: 'AR51-support'
# EMXIF

# gem 'script_relocator' # TODO(uwe): Messes up the design.  Why?!
gem 'simple_drilldown'
gem 'simple_workflow'
gem 'slim-rails'
gem 'tinymce-rails'
gem 'tinymce-rails-langs'
gem 'uglifier'
gem 'unicode_utils'
gem 'will_paginate'

group :beta, :email, :production do
  gem 'lograge'
end

group :development do
  gem 'capistrano', '<3.9'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-scm-copy'
  gem 'listen'
end

group :test do
  gem 'bullet'
  gem 'capybara-screenshot-diff'
  # gem 'capybara-screenshot-diff', path: '~/work/open-source/capybara-screenshot-diff'
  gem 'chunky_png'
  gem 'database_cleaner'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'mocha', require: 'mocha/setup'
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
