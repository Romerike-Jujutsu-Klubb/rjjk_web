#!/usr/bin/env ruby

require 'shellwords'
require 'mail'
require 'nokogiri'

Dir.chdir File.expand_path '..', __dir__

files = Dir['mail_*']
sorted = files.sort_by { |f| f[0..24] }

def check_if_spam(escaped_filename)
  spam_status = `spamc < #{escaped_filename} | grep 'X-Spam-Status'`
  puts spam_status
end

def learn(escaped_filename, type)
  check_if_spam(escaped_filename)
  system(%{sa-learn -u capistrano --#{type} "#{escaped_filename}"}) || raise('learning spam failed')
  check_if_spam(escaped_filename)
  puts
end

def text_from_part(m)
  body = m.body.decoded
  if (encoding = m.content_type_parameters['charset'])
    puts "Convert to #{encoding.inspect}"
    body.force_encoding(encoding)
  end
  if m.content_type =~ %r{text/html}
    doc = Nokogiri::HTML(body)
    doc.css('script, link').each { |node| node.remove }
    doc.css('body').text.gsub(/^\s+/, '').squeeze(" \n\t")
  else
    body
  end
end

sorted.each.with_index do |f, i|

  if f.valid_encoding?
    escaped_filename = Shellwords.escape(f)
    loop do
      print "[#{files.size - i}] #{f.gsub(/^mail_/, '')}: "
      q = gets.chomp
      if q == 's'
        learn(escaped_filename, 'spam')
        break
      elsif q == 'h'
        learn(escaped_filename, 'ham')
        break
      elsif q == 'd'
        puts
        m = Mail.read_from_string(File.read(f))
        puts "From: #{m['from']}"
        puts "To: #{m['to']}"
        puts "Subject: #{m['subject']}"
        puts
        if m.multipart?
          m.parts.each do |part|
            puts part.content_type
            next unless part.content_type =~ /text/
            puts text_from_part(part)
            puts
          end
        else
          puts text_from_part(m)
          puts
        end
        puts
      elsif q == ''
        puts if i == sorted.size - 1
        break
      end
    end
  else
    puts "[#{files.size - i}] #{f} [BAD ENCODING]"
  end

  File.delete f
end

system(%{sa-learn --sync}) || raise('syncing learned spam failed')
