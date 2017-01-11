# frozen_string_literal: true
set :application, 'rjjk_web'
set :scm, :git
set :repo_url, "https://github.com/Romerike-Jujutsu-Klubb/#{fetch :application}.git"
set :deploy_to, -> { "/u/apps/#{fetch :application}" }
set :keep_releases, 30

role :app, %w(capistrano@kubosch.no)
role :web, %w(capistrano@kubosch.no)
role :db,  %w(capistrano@kubosch.no)

server 'kubosch.no', user: 'capistrano', roles: %w(web app)
