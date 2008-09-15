#!/usr/bin/env /usr/local/jruby/bin/jruby

IMPORT_DIR = '/media/Lexar'
ENVIRONMENT = 'development'

require 'yaml'

def load(model_plural)
  puts "Importing #{model_plural}"
  require model_plural.to_s.singularize
  model_class = eval model_plural.to_s.singularize.camelize
  records = YAML.load_file("#{IMPORT_DIR}/#{model_plural}.yml")
  records.each do |r|
    begin
      # MUST SYNCHRONIZE IDs!!!
      existing = model_class.find_by_id(r.id)
      existing = model_class.find_by_first_name_and_last_name(r.first_name, r.last_name) if r.respond_to? :rfid
      if existing  
        existing.update_attributes! r.attributes
      else
        # MUST SYNCHRONIZE IDs!!!
        new_record = model_class.create! r.attributes
        # model_class.update_all("id = #{r.id}", "id = #{new_record.id}")
      end
    rescue
      puts $!.message
      puts $!.backtrace
      raise $!
    end
  end
end

if File.exists? IMPORT_DIR
  #  ActiveRecord::Base.transaction do
  load :members
  load :martial_arts
  load :groups
  load :group_schedules
  #  end
else
  puts "USB stick on '#{IMPORT_DIR}' not found!"
end
