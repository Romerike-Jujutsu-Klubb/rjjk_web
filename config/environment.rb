RAILS_GEM_VERSION = '~>2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.i18n.default_locale = :nb
  
  config.action_controller.session = { :key => "_rjjk_web_session", :secret => "Norges peneste jujutsu klubb. Man må like å lide!" }
  
  config.gem 'jruby-openssl', :lib => false
  config.gem 'rmagick4j', :lib => false
  config.gem 'jdbc-postgres', :lib => false
  config.gem 'activerecord-jdbcpostgresql-adapter', :lib => false
  config.gem 'RedCloth'
  config.gem 'gruff'
end

#require '/config/environments/user_environment'
require 'config/environments/user_environment'
require 'csv'
