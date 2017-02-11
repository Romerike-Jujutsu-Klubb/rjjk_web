#!/usr/bin/env ruby

require 'shellwords'

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

sorted.each.with_index do |f, i|
  print "[#{files.size - i}] #{f}: "

  if f.valid_encoding?
    escaped_filename = Shellwords.escape(f)
    loop do
      q = gets.chomp
      if q == 's'
        learn(escaped_filename, 'spam')
        break
      elsif q == 'h'
        learn(escaped_filename, 'ham')
        break
      elsif q == ''
        puts if i == sorted.size - 1
        break
      end
    end
  else
    puts
  end

  File.delete f
end

system(%{sa-learn --sync}) || raise('syncing learned spam failed')
