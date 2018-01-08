# frozen_string_literal: true

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

if Rails.env.test?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  # require 'rubycritic/rake_task'
  # RubyCritic::RakeTask.new

  namespace :test do
    desc 'Run Rubocop and all tests'
    task full: %i[rubocop:auto_correct test test:system]
    # task(:test) { Rake::Task[:rubycritic].invoke }

    desc 'Run all tests except system tests'
    task quick: :test
  end
end

task 'db:schema:dump' do
  sh 'rubocop --auto-correct db/schema.rb > /dev/null'
  filename = 'db/schema.rb'
  schema = File.read(filename)
      .gsub(', id: :serial', '')
      .gsub(/, id: :integer, default: -> { "nextval\('instructions_id_seq'::regclass\)" }/, '')
  File.write(filename, schema)
end
