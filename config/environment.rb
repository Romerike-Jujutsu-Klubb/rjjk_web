# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '~>2.3.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.action_controller.session = { :session_key => "_myapp_session", :secret => "Norges peneste jujutsu klubb. Man må like å lide!" }
  
  config.gem 'jruby-openssl', :lib => false
  config.gem 'rmagick4j', :lib => false
  config.gem 'jdbc-postgres', :lib => false
  config.gem 'activerecord-jdbcpostgresql-adapter', :lib => false
  config.gem 'RedCloth'
  config.gem 'gruff'
  config.gem 'mongrel'
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

require 'config/environments/user_environment'
require 'csv'

# FIXME(uwe): fix for activerecord-jdbc-adapter 0.9.  report bugs, remove fixes when fixed in jruby-postgres adaptor
module ::JdbcSpec::PostgreSQL
  def change_column_null(table_name, column_name, null, default = nil)
    unless null || default.nil?
      execute("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(column_name)}=#{quote(default)} WHERE #{quote_column_name(column_name)} IS NULL")
    end
    execute("ALTER TABLE #{quote_table_name(table_name)} ALTER #{quote_column_name(column_name)} #{null ? 'DROP' : 'SET'} NOT NULL")
  end

  def add_column(table_name, column_name, type, options = {})
    default = options[:default]
    notnull = options[:null] == false

    # Add the column.
    execute("ALTER TABLE #{quote_table_name(table_name)} ADD COLUMN #{quote_column_name(column_name)} #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}")

    change_column_default(table_name, column_name, default) if options_include_default?(options)
    change_column_null(table_name, column_name, false, default) if notnull
  end
end
