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

SPAM_AUTOLEARN_LIMIT = 5.0
PROMPT_COLUMN = 110

def check_if_spam(escaped_filename)
  `spamc < #{escaped_filename} | grep 'X-Spam-Status'`
end

def learn_file(escaped_filename, type)
  system(%(sa-learn -u capistrano --#{type} "#{escaped_filename}")) || raise('learning spam failed')
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

def check_and_learn_if_spam(f, escaped_filename)
  skip = false
  new_spam_status = check_if_spam(escaped_filename)
  if /X-Spam-Status: (Yes|No), score=(?<spam_score>-?\d+\.\d+) / =~ new_spam_status
    print "[#{spam_score}] : ".rjust(PROMPT_COLUMN - f.size, ' ')
    if spam_score.to_f >= SPAM_AUTOLEARN_LIMIT
      puts 'LEARNING'
      learn_file(escaped_filename, 'spam')
      skip = true
    end
  end
  skip
end

def learn(interactive)
  sorted = Dir['mail_*'].sort_by { |f| f[0..24] }

  sorted.each.with_index do |f, i|
    if f.valid_encoding?
      escaped_filename = Shellwords.escape(f)
      delete = loop do
        print "[#{sorted.size - i}] #{f.gsub(/^mail_/, '')}"

        file_date = Time.zone.parse(f[5..14] + 'T' + f[16..23])
        if file_date < 2.days.ago
          puts ': OLD'.rjust(PROMPT_COLUMN - f.size, ' ')
          break true
        end

        /\[SPAM\]\[(?<old_spam_score>\d+\.\d+)\]/ =~ f
        if old_spam_score
          break true if check_and_learn_if_spam(f, escaped_filename)
        elsif /______\[(?<old_ham_score>-\d+\.\d+)\]/ =~ f
          print ': '.rjust(PROMPT_COLUMN - f.size, ' ')
          if old_ham_score.to_f <= -2.0
            puts 'HAM'
            break true
          end
        else
          print ': '.rjust(PROMPT_COLUMN - f.size, ' ')
        end

        unless interactive
          puts
          break false
        end

        q = gets.chomp
        if q == 's'
          learn_file(escaped_filename, 'spam')
          break true
        elsif q == 'h'
          learn_file(escaped_filename, 'ham')
          break true
        elsif q == 'd'
          print "\e[3J"
          m = Mail.read(f)
          puts "From: #{m['from']}"
          puts "To: #{m['to']}"
          puts "Subject: #{m['subject']}"
          puts
          puts text_from_part(m)
          puts
          puts
        elsif q == 'c'
          break true if check_and_learn_if_spam(f, escaped_filename)
        elsif q == ''
          puts if i == sorted.size - 1
          break true
        end
      end
    else
      puts "[#{sorted.size - i}] #{f} [BAD ENCODING]"
      delete = true
    end

    File.delete(f) if delete
  end
end

Time.zone = 'Copenhagen'
Dir.chdir File.expand_path '..', __dir__

learn(false)
puts
learn(true)

system(%(sa-learn --sync)) || raise('syncing learned spam failed')
