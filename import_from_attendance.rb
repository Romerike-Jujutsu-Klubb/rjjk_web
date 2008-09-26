#!/usr/bin/ruby -w

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
EXPORT_DIR = '/media/Lexar'

$: << PROJECT_DIR

require 'config/boot'
require 'config/environment'
require 'yaml'
require 'member'

def load(model_plural)
  eval model_plural.to_s.singularize.camelize
  records = YAML.load_file("#{EXPORT_DIR}/#{model_plural}.yml")
  records.each do |r|
    r.save!
  end
end

if File.exists? '/media/Lexar'
  load :attendances
else
  puts "USB stick on '#{EXPORT_DIR}' not found!"
  exit
end

members = YAML.load_file(EXPORT_DIR + '/members.yml')
members.each do |m|
p m
p m.attributes
p m.id
  existing_member = Member.find(m.id)
  if existing_member.rfid != m.rfid
    puts "Updating rfid for #{m.name}"
    existing_member.rfid = m.rfid
    existing_member.save!
  end
end
