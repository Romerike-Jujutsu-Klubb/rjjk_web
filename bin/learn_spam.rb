#!/usr/bin/env ruby
# frozen_string_literal: true

require 'shellwords'
require 'mail'
require 'nokogiri'
require 'time'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'active_support/core_ext/date_time'

Dir.chdir File.expand_path '..', __dir__

files = Dir['mail_*']
sorted = files.sort_by { |f| f[0..24] }

def check_if_spam(escaped_filename)
  `spamc < #{escaped_filename} | grep 'X-Spam-Status'`
end

def learn(escaped_filename, type)
  system(%(sa-learn -u capistrano --#{type} "#{escaped_filename}")) || raise('learning spam failed')
  puts check_if_spam(escaped_filename)
  puts
end

def text_from_part(m)
  if m.multipart?
    "#{m.content_type}\n" + m.parts.map do |part|
      text_from_part(part)
    end.join("\n")
  else
    header = "#{m.content_type}\n"
    body = m.body.decoded
    if (encoding = m.content_type_parameters && m.content_type_parameters['charset'])
      body.force_encoding(encoding)
      header << "Convert to #{encoding.inspect}\n"
    end
    pretty_body =
        if m.content_type =~ %r{text/html}
          doc = Nokogiri::HTML(body)
          doc.css('script, link').each(&:remove)
          doc.css('body').text.gsub(/^\s+/, '').squeeze(" \n\t")
        elsif m.content_type =~ /text/
          body
        end
    "#{header}#{pretty_body}".encode(Encoding::UTF_8, undef: :replace)
  end
end

sorted.each.with_index do |f, i|
  if f.valid_encoding?
    escaped_filename = Shellwords.escape(f)
    loop do
      print "[#{files.size - i}] #{f.gsub(/^mail_/, '')} "

      /\[SPAM\]\[(?<old_spam_score>\d+\.\d+)\]/ =~ f
      if old_spam_score && old_spam_score.to_f >= 5.0
        new_spam_status = check_if_spam(escaped_filename)
        if /X-Spam-Status: Yes, score=(?<spam_score>\d+\.\d+) / =~ new_spam_status
          print "[#{spam_score}] : "
          if spam_score.to_f >= 7.5
            puts 'LEARNING'
            learn(escaped_filename, 'spam')
            break
          end
        end
      else
        print ': '
      end

      file_date = Time.parse(f[5..14] + 'T' + f[16..23])
      if file_date < 2.days.ago
        puts 'OLD'
        break
      end

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
        puts text_from_part(m)
        puts
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

system(%(sa-learn --sync)) || raise('syncing learned spam failed')
