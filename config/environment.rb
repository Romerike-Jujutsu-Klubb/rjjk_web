RAILS_GEM_VERSION = '~>2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone                 = 'UTC'
  config.i18n.default_locale       = :nb
  config.action_controller.session = {:key => "_rjjk_web_session", :secret => "Norges peneste jujutsu klubb. Man må like å lide!"}
  config.logger = Logger.new(config.log_path, 7, 10 * 1024**2)
end

require 'config/environments/user_environment'
require 'csv'

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def using_cast(column_name, type, options)
    return "" if postgresql_version < 80000
    " USING CAST(#{quote_column_name(column_name)} AS #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
  end

  def change_column(table_name, column_name, type, options = {})
    quoted_table_name = quote_table_name(table_name)
    execute "ALTER TABLE #{quoted_table_name} ALTER COLUMN #{quote_column_name(column_name)} TYPE #{type_to_sql(type, options[:limit], options[:precision],
                                                                                                                options[:scale])}#{using_cast(column_name, type, options)})"
  end
end

module ::ArJdbc
  module PostgreSQL
    def using_cast(column_name, type, options)
      return "" if postgresql_version < 80000
      " USING CAST(#{quote_column_name(column_name)} AS #{type_to_sql(type, options[:limit], options[:precision], options[:scale])}"
    end

    def change_column(table_name, column_name, type, options = {})
      quoted_table_name = quote_table_name(table_name)
      execute "ALTER TABLE #{quoted_table_name} ALTER COLUMN #{quote_column_name(column_name)} TYPE #{type_to_sql(type, options[:limit], options[:precision],
                                                                                                                  options[:scale])}#{using_cast(column_name, type, options)})"
    end
  end
end
