# frozen_string_literal: true

source 'https://rubygems.org/'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby File.read("#{__dir__}/.ruby-version")[5..-1]

gem 'rails', '~>5.2.0'

platform :ruby do
  gem 'mini_racer'
  gem 'oily_png'
  gem 'pg'
end

gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
gem 'activerecord-time'
gem 'acts_as_list' # https://github.com/swanandp/acts_as_list/pull/283
gem 'acts_as_tree'
gem 'bcrypt'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap'
gem 'bootstrap-chosen-rails', github: 'donv/bootstrap-chosen-rails'
gem 'bootstrap3-datetimepicker-rails'
gem 'bootstrap_form'
gem 'chartkick'
gem 'chosen-rails'
gem 'coffee-rails'
gem 'dynamic_form'
gem 'exception_notification'
gem 'font-awesome-rails'
gem 'geocoder'
gem 'google_drive'
# gem 'gruff'
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
gem 'paranoia'
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'rack-attack'
gem 'rails-assets-tether'
gem 'rails-i18n'
gem 'rails-observers', github: 'rails/rails-observers'
gem 'rails_autolink'
gem 'rake'
gem 'ri_cal'
gem 'rufus-scheduler'
gem 'sass-rails'
# gem 'script_relocator' # TODO(uwe): Messes up the design.  Why?!
gem 'serviceworker-rails'
gem 'simple_drilldown'
gem 'simple_workflow'
gem 'slim-rails'
gem 'uglifier', '<4'
gem 'unicode_utils'
gem 'webpush'

group :beta, :email, :production do
  gem 'lograge'
end

group :development, :beta do
  gem 'rack-mini-profiler'
end

group :development do
  gem 'listen'
end

group :test do
  # gem 'bullet'
  gem 'capybara-screenshot-diff' # , path: '~/work/open-source/capybara-screenshot-diff'
  gem 'chunky_png'
  # gem 'coveralls', require: false
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
end
