#!/usr/bin/env jruby

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
IMPORT_DIR_PROD = '/home/donv/backup_laptop/workspace/KC/RJJK/pensum/2010'
if File.exists? IMPORT_DIR_PROD
  system "svn up #{IMPORT_DIR_PROD}"
  IMPORT_DIR = IMPORT_DIR_PROD
else
  IMPORT_DIR = File.expand_path '../RJJK/pensum/2010', PROJECT_DIR
end

DUMP = ARGV.include? '-d'

if DUMP
  puts 'Only dumping.  No storing.'
  require 'nokogiri'
elsif !defined?(Rails)
  require 'config/boot'
  require 'config/environment'
end

require 'martial_art'
require 'group'
require 'application_step'
require 'technique_application'
require 'rank'
require 'waza'
require 'basic_technique'

ranks = [['5. kyu', 'gult'], ['4. kyu', 'oransje'], ['3. kyu', 'groent'],
    ['2. kyu', 'blaatt'], ['1. kyu', 'brunt'], ['1. dan', 'shodan']]
kwr = MartialArt.where(name: 'Kei Wa Ryu').first! unless DUMP
ranks.each do |rank_name, rank_dir|
  rank = Rank.where(name: rank_name, martial_art_id: kwr.id).first unless DUMP
  puts '*' * 80
  puts "#{rank_dir} pensum"
  puts '*' * 80
  Dir.chdir("#{IMPORT_DIR}/#{rank_dir}") do
    manifest = Nokogiri::HTML(File.read('pensum.html')) { |c| c.strict.nonet }
    appendix = manifest.css('head link').map do |link|
      Nokogiri::HTML(File.read link['href']).css('body').children.to_html
    end.join

    doc = Nokogiri::HTML(manifest.css('body').children.to_html + appendix)

    puts
    puts 'Beskrivelse'
    puts

    rank_desc = doc.css('p.description').map(&:content).join("\n")
    puts rank_desc
    rank.update_attributes!(description: rank_desc) unless DUMP
    puts

    puts
    puts 'Grunnteknikker'
    puts

    basic = doc.css('div.section.basic pre').map(&:content).join
    lines = basic.split("\n")
    joined = lines.each_cons(2).map do |l1, l2|
      if l2 !~ /:/
        l1.strip + ' ' + l2.strip
      else
        (l1 =~ /:/) ? l1 : nil
      end
    end.compact.flatten

    split = joined.map { |l| l.split(':').map(&:strip) }
    basics = split.map { |n, t| [n.sub(/\s+waza\s*/, ''), t.split(/,\s*/).map(&:downcase)] }
    basics.each do |waza_name, tecs|
      puts "#{waza_name && waza_name.strip}: #{tecs.inspect}"
      unless DUMP
        waza = Waza.where(:name => waza_name).first_or_create!
      end
      tecs.each do |t|
        unless DUMP
          begin
            bt = waza.basic_techniques.
                where(BasicTechnique.arel_table[:name].matches(t)).
                first_or_create!(name: t)
            bt.update_attributes!(name: t, rank_id: rank.id)
          rescue
            puts "Failed: #{t}: #{$!}"
          end
        end
      end
    end

    puts
    puts 'Applikasjoner'
    puts
    # find all sections filter for apps and iterate
    applications = doc.css('div.section h3').map(&:parent)
    applications.each do |a|
      name = a.css('h3').first.content.strip
      puts "#{name}:"
      begin
        unless DUMP
          ta = TechniqueApplication.where(name: name, rank_id: rank.id).
              first_or_create!
          ta.update_attributes! kata: !!(name =~ /giwaken|tenshiken/i)
          ta.application_steps.delete_all
        end
        steps = a.css('p')
        steps.to_a.each.with_index do |sd, i|
          desc = sd.content.strip
          image = sd.css('img').first
          filename = image[:src] if image
          puts "  #{i + 1}: #{desc} #{"[#{filename}]" if image}"
          unless DUMP
            as = ApplicationStep.create!(technique_application_id: ta.id,
                position: i + 1, description: desc)
            if image
              as.update_attributes! image_content_data: File.read(filename),
                  image_content_type: 'image/jpeg', image_filename: filename
            end
          end
        end
      rescue
        puts "Failed: #{name}: #{$!}"
        puts $!.backtrace.join("\n")
      end
      puts
    end
  end
end
