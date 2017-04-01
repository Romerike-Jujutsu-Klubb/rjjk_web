# frozen_string_literal: true

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

if Rails.env.test?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  # require 'rubycritic/rake_task'
  # RubyCritic::RakeTask.new

  namespace :test do
    task full: %i(rubocop:auto_correct test)
    # task(:test) { Rake::Task[:rubycritic].invoke }
  end
end
