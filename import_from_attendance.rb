#!/usr/bin/ruby -w

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
IMPORT_DIR = '/media/Lexar'

$: << PROJECT_DIR

require 'config/boot'
require 'config/environment'
require 'yaml'

def load(model_plural)
  model_class = eval model_plural.to_s.singularize.camelize
  records = YAML.load_file(EXPORT_DIR + '/' + model_plural + '.yml')
  records.each do |r|
    r.save!
  end
end

if File.exists? '/media/Lexar'
  load :attendances
else
  puts "USB stick on '#{EXPORT_DIR}' not found!"
end
