#!/usr/bin/env jruby

PROJECT_DIR = File.expand_path(File.dirname(__FILE__))
IMPORT_DIR = File.expand_path '../RJJK/pensum/2010', PROJECT_DIR
$: << PROJECT_DIR
require 'config/boot'
require 'config/environment'

ranks = [['5. kyu', 'gult'], ['4. kyu', 'oransje']]
kwr = MartialArt.where(name: 'Kei Wa Ryu').first!
ranks.each do |rank_name, rank_dir|
  rank = Rank.where(name: rank_name, martial_art_id: kwr.id).first
  puts '*' * 80
  puts "Loading #{rank_dir}"
  puts '*' * 80
  Dir.chdir("#{IMPORT_DIR}/#{rank_dir}") do
    manifest = Nokogiri::HTML(File.read('pensum.html')) { |c| c.strict.nonet }
    appendix = manifest.css('head link').map do |link|
      Nokogiri::HTML(File.read link['href']).css('body').children.to_html
    end.join

    doc = Nokogiri::HTML(manifest.css('body').children.to_html + appendix)

    applications = doc.css('div.section h3').map(&:content).map(&:strip)
    applications.each do |a|
      begin
        ta = TechniqueApplication.where(name: a, rank_id: rank.id).first_or_create!
        p ta
      rescue
        puts "Failed: #{a}: #{$!}"
      end
    end

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
      puts "#{waza_name.try(:strip)}: #{tecs.inspect}"
      waza = Waza.where(:name => waza_name).first_or_create!
      p waza
      tecs.each do |t|
        begin
          bt = waza.basic_techniques.
              where(BasicTechnique.arel_table[:name].matches(t)).
              first_or_create!(name: t)
          bt.update_attributes!(name: t, rank_id: rank.id)
          p bt
        rescue
          puts "Failed: #{t}: #{$!}"
        end
      end
    end
  end
end
