require 'rails_generator'  

class ScaffoldFromDbGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      columns = ActiveRecord::Base.connection.columns(plural_name)
      column_args = columns.map{|c| "#{c.name.to_s}:#{c.type}" unless ['id', 'created_at', 'updated_at'].include? c.name}.compact
      
      m.dependency 'scaffold', [name] + column_args + ['--skip-migration'] + @args
    end
  end

  def banner
    "Usage: #{$0} scaffold_from_db ModelName"
  end
    
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps",
           "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
  end

end
