require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rails::TestTask.new('test:features' => 'test:prepare') do |t|
  t.pattern = 'test/features/**/*_test.rb'
end
Rake::Task['test:run'].enhance ['test:features']

require 'rubocop/rake_task'
RuboCop::RakeTask.new
Rake::Task[:test].enhance(['rubocop:auto_correct'])
