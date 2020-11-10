# frozen_string_literal: true

source 'https://rubygems.org/'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby File.read("#{__dir__}/.ruby-version")[5..]

# For Rails 6
# https://gorails.com/episodes/how-to-use-bootstrap-with-webpack-and-rails

gem 'rails', '~>6.0.0'

platform :ruby do
  gem 'oily_png'
  gem 'pg'
end

# https://github.com/styd/apexcharts.rb
# https://github.com/apexcharts

gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
gem 'activerecord-time' # , path: '~/work/open-source/activerecord-time'
gem 'activestorage-database-service', github: 'TitovDigital/activestorage-database-service'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'bcrypt'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap-chosen-rails', github: 'donv/bootstrap-chosen-rails'
gem 'bootstrap_form'
gem 'chartkick'
gem 'chosen-rails'
gem 'cloudinary'
gem 'deep_cloneable', '~> 3.0'
gem 'exception_notification'
gem 'geocoder'
gem 'google_drive'
gem 'http'
gem 'invisible_captcha'
gem 'jbuilder'
gem 'jquery-ui-rails'
gem 'kramdown'
gem 'lazyload-rails'
gem 'mechanize'
gem 'mini_magick'
gem 'nokogiri'
gem 'oauth2'
gem 'paper_trail'
gem 'paranoia'
gem 'prawn'
gem 'prawn-grouping'
gem 'prawn-table'
gem 'puma'
gem 'rack-attack'
gem 'rails_autolink'
gem 'rails-i18n'
gem 'rails-observers', github: 'rails/rails-observers'
gem 'rake'
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sassc-rails'
gem 'script_relocator'
gem 'serviceworker-rails'
gem 'simple_drilldown' # , path: '~/work/simple_drilldown'
gem 'simple_workflow' # , path: '~/work/open-source/simple_workflow'
gem 'slim-rails'
gem 'uglifier'
gem 'webpacker'
gem 'webpush'

group :beta, :production do
  gem 'lograge'
end

group :production do
  gem 'redis', '~> 4.0'
end

group :development do
  # gem 'derailed'
  gem 'listen'
end

group :development, :production do
  gem 'flamegraph'
  gem 'memory_profiler'
  gem 'rack-mini-profiler'
  gem 'stackprof'
end

# group :development do
#   gem 'meta_request'
# end

group :test do
  # https://github.com/twalpole/apparition
  # gem 'apparition', github: 'twalpole/apparition'
  # gem 'bullet' # Uncomment to hunt N+1 kind of problems
  gem 'capybara-screenshot-diff' # , path: '~/work/open-source/capybara-screenshot-diff'
  gem 'chunky_png'
  gem 'minitest-capybara'
  gem 'mocha', require: 'mocha/minitest'
  gem 'nokogiri-diff'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # gem 'rubycritic', require: false
  gem 'selenium-webdriver'
  # gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
