#!/usr/bin/ruby

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
# EXPORT_DIR = '/media/Lexar'
EXPORT_DIR = '/media/USBBOOT'
# EXPORT_DIR = '/tmp'

$: << PROJECT_DIR

require 'config/boot'
require 'config/environment'
require 'yaml'

def dump(model_plural)
  model_class = model_plural.to_s.singularize.camelize.constantize
  models = model_class.all
  puts "Found #{models.size} #{model_plural}"
  models.each { |m| m.image = m.thumbnail } if model_class == Member
  File.open("#{EXPORT_DIR}/#{model_plural}.yml", 'w') do |outfile|
    outfile << YAML.dump(models)
  end
end

if File.exist? EXPORT_DIR
  dump :members
  dump :martial_arts
  dump :groups
  dump :group_schedules
else
  puts "USB stick on '#{EXPORT_DIR}' not found!"
end
