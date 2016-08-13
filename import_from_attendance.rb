#!/usr/bin/ruby

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
EXPORT_DIR = '/main'

$: << PROJECT_DIR

require 'config/boot'
require 'config/environment'
require 'yaml'
require 'member'

def load(model_plural)
  puts "Loading #{model_plural}"
  model_plural.to_s.singularize.camelize.constantize
  records = YAML.load_file("#{EXPORT_DIR}/#{model_plural}.yml")
  records.each do |r|
    attendance = Attendance.find_by_member_id_and_year_and_week_and_group_schedule_id(r.member_id, r.year, r.week, r.group_schedule_id)
    if attendance.nil?
      puts "Adding attendance for #{r.member.name} year #{r.year}, week: #{r.week}, group: #{r.group_schedule.group.name}"
      Attendance.create! :member_id => r.member_id, :year => r.year, :week => r.week, :group_schedule_id => r.group_schedule_id
    end
  end
end

if File.exist? EXPORT_DIR
  load :attendances
else
  puts "USB stick on '#{EXPORT_DIR}' not found!"
  exit
end

members = YAML.load_file(EXPORT_DIR + '/members.yml')
members.each do |m|
  existing_member = Member.find(m.id)
  if existing_member.rfid != m.rfid
    puts "Updating rfid for #{m.name}"
    existing_member.rfid = m.rfid
    existing_member.save!
  end
end
