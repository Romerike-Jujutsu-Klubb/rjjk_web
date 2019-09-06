# frozen_string_literal: true

source 'https://rubygems.org/'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby File.read("#{__dir__}/.ruby-version")[5..-1]

# For Rails 6
# https://gorails.com/episodes/how-to-use-bootstrap-with-webpack-and-rails

gem 'rails', '~>5.2.0'

platform :ruby do
  gem 'mini_racer'
  gem 'oily_png'
  gem 'pg'
end

# https://github.com/styd/apexcharts.rb
# https://github.com/apexcharts

gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
gem 'activerecord-time'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'bcrypt'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap'
gem 'bootstrap-chosen-rails', github: 'donv/bootstrap-chosen-rails'
gem 'bootstrap_form'
gem 'chartkick'
gem 'chosen-rails'
gem 'coffee-rails'
gem 'dynamic_form'
gem 'exception_notification'
gem 'geocoder'
gem 'google_drive'
gem 'http'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kramdown'
gem 'lazyload-rails'
gem 'mechanize'
gem 'mini_magick'
gem 'momentjs-rails'
gem 'nokogiri'
gem 'nprogress-rails'
gem 'oauth2'
gem 'paper_trail'
gem 'paranoia'
gem 'prawn'
gem 'prawn-grouping'
gem 'prawn-table'
gem 'puma'
gem 'rack-attack'
gem 'rails-i18n'
gem 'rails-observers', github: 'rails/rails-observers'
gem 'rails_autolink'
gem 'rake'
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sassc-rails'
gem 'script_relocator'
gem 'serviceworker-rails'
gem 'simple_drilldown'
gem 'simple_workflow'
gem 'slim-rails'
# gem 'tunemygc'
gem 'uglifier', '<4'
gem 'unicode_utils'
gem 'webpush'

group :beta, :production do
  gem 'lograge'
end

group :production do
  gem 'newrelic_rpm'
  gem 'redis', '~> 4.0'
end

group :development do
  gem 'derailed'
  gem 'listen'
  gem 'rack-mini-profiler'
end

# group :development do
#   gem 'meta_request'
# end

group :test do
  # gem 'bullet' # Uncomment to hunt N+1 kind of problems
  gem 'capybara-screenshot-diff' # , path: '~/work/open-source/capybara-screenshot-diff'
  gem 'chunky_png'
  # gem 'coveralls', require: false
  gem 'minitest-capybara'
  gem 'minitest-metadata'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'mocha', require: 'mocha/setup'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # gem 'rubycritic', require: false
  # https://github.com/twalpole/apparition
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
