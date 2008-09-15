#!/usr/bin/ruby

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
EXPORT_DIR = '/media/Lexar'

$: << PROJECT_DIR

require 'config/boot'
require 'config/environment'
require 'yaml'

def dump(model_plural)
  model_class = eval model_plural.to_s.singularize.camelize
  models = model_class.find(:all)
  models.each{|m| m.image = m.image} if models.size > 0 && models[0].respond_to?(:image)
  File.open("#{EXPORT_DIR}/#{model_plural}.yml", 'w') do |outfile|
    outfile << YAML.dump(models)
  end
end

if File.exists? '/media/Lexar'
  dump :members
  dump :martial_arts
  dump :groups
  dump :group_schedules
else
  puts "USB stick on '#{EXPORT_DIR}' not found!"
end
