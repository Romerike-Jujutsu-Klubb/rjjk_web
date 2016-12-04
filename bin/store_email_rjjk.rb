#!/usr/bin/env ruby
# frozen_string_literal: true

started_at = Time.now

def log(message = nil)
  open('log/email.log', 'a') do |f|
    f.puts message
  end
rescue Exception => e # rubocop: disable  Lint/RescueException
  puts e
end

from = ARGV[0]
to = ARGV[1..-1]

Dir.chdir File.expand_path('..', __dir__)

log "#{started_at.strftime('%F %T')} Got email From: #{from}, To: #{to}"

if to == ['noreply@beta.jujutsu.no']
  log "Ignore recipient: #{to}"
  exit 0
end

content = $stdin.read

# Exit codes from <sysexits.h>
EX_TEMPFAIL = 75
EX_UNAVAILABLE = 69

if content.size <= 512_000
  spam_start = Time.now
  begin
    require 'open3'
    log 'Checking Spamassassin'
    Open3.popen3('spamc') do |stdin, stdout, stderr, wait_thr|
      log 'Spamassassin: send content to process'
      stdin << content
      log 'Spamassassin: close stdin'
      stdin.close
      log 'Spamassassin: read stdout'
      content = stdout.read
      log "Spamassassin: #{content}"
      log 'Spamassassin: read stderr'
      log "Spamassassin: #{stderr.read}"
      log 'Spamassassin: finish process'
      exit_status = wait_thr.value # Process::Status object returned.
      log "Spamassassin reported: #{exit_status.inspect}"
      if content.encode(Encoding::BINARY) =~ /^X-Spam-Status: Yes/
        log 'Mail is SPAM.'
        # exit 1
      end
    end
  rescue Exception => e # rubocop: disable Lint/RescueException
    log "Exception scanning for SPAM: #{e}"
  end
  log "Spam check took: #{Time.now - spam_start}s"
else
  log "Large message: #{content.size} bytes.  Skipping spam detection."
end

prod_recipients = to.grep(/@jujutsu.no/)
beta_recipients = to.grep(/@beta.jujutsu.no/)
rest_recipients = to - prod_recipients - beta_recipients

def create_record(env, from, recipients, content)
  require 'bundler/setup'
  require 'active_record'
  require_relative '../app/models/raw_incoming_email'
  log "Storing in #{env} to: #{from} => #{recipients}"

  content_with_envelope = <<EOF + content
X-Envelope-From: #{from}
X-Envelope-To: #{recipients.join(', ')}
EOF

  RawIncomingEmail.configurations = YAML.load_file('config/database.yml')
  RawIncomingEmail.establish_connection(env)
  RawIncomingEmail.create content: content_with_envelope
rescue Exception => e # rubocop: disable Lint/RescueException
  log "Exception storing record: #{e}"
  exit EX_TEMPFAIL
end

if prod_recipients.any?
  create_record('production', from, prod_recipients, content)
end

create_record('beta', from, beta_recipients, content) if beta_recipients.any?

if rest_recipients.any?
  require 'bundler/setup'
  require 'mail'
  log "Sending to rest: #{from} => #{rest_recipients}"
  begin
    log content.encode(Encoding::BINARY).lines.grep(/spam/i)
  rescue Exception => e # rubocop: disable Lint/RescueException
    puts e
    log "Exception logging spam lines: #{e}"
    log "Content Encoding: #{content.encoding}"
  end
  begin
    mail = Mail.read_from_string(content)
    mail.smtp_envelope_from = from
    mail.smtp_envelope_to = rest_recipients
    mail.delivery_method :sendmail
    mail.deliver
    log "\nDelivered OK to #{rest_recipients}"
  rescue => e
    log "Exception sending email: #{e}"
    log e.backtrace.join("\n")
    File.write("bad_email-#{Time.now.strftime('%F_%T')}", content)
    exit 1
  end
end

finished_at = Time.now
log "\n#{finished_at.strftime('%F %T')} Finished in #{finished_at - started_at}s\n\n"

exit 0
