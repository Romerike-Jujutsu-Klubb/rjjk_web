# frozen_string_literal: true
namespace :rvm do
  desc 'Install the desired Ruby version'
  task :install do
    on roles(fetch(:rvm_roles, :all)) do
      execute(:rvm, "install #{fetch :rvm_ruby_version}")
      execute(:ruby, '-S gem install bundler')
    end
  end
end

before 'rvm:check', 'rvm:install'
