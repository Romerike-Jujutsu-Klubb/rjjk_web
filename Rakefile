# frozen_string_literal: true
require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

if Rails.env.test?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  Rake::Task[:test].enhance([:'rubocop:auto_correct'])

  # require 'rubycritic/rake_task'
  # RubyCritic::RakeTask.new
  # task(:test) { Rake::Task[:rubycritic].invoke }
end
