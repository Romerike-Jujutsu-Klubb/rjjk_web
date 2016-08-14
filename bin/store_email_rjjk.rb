#!/usr/bin/env ruby

started_at = Time.now

from = ARGV[0]
to = ARGV[1..-1]

Dir.chdir File.expand_path('..', __dir__)

def log(message = nil)
  open('log/email.log', 'a') do |f|
    f.puts message
  end
rescue Exception
  puts $!
end

if to == ['noreply@beta.jujutsu.no']
  log "Ignore recipient: #{to}"
  exit 0
end

log
log "From: #{from}"
log "To: #{to}"

content = $stdin.read

# Exit codes from <sysexits.h>
EX_TEMPFAIL = 75
EX_UNAVAILABLE = 69

spam_start = Time.now
begin
  require 'open3'
  log 'Checking Spamassassin'
  Open3.popen3('spamc') do |stdin, stdout, stderr, wait_thr|
    log "Spamassassin: send content to process"
    stdin << content
    log "Spamassassin: close stdin"
    stdin.close
    log "Spamassassin: read stdout"
    content = stdout.read
    log "Spamassassin: #{content}"
    log "Spamassassin: read stderr"
    log "Spamassassin: #{stderr.read}"
    log "Spamassassin: finish process"
    exit_status = wait_thr.value # Process::Status object returned.
    log "Spamassassin reported: #{exit_status.inspect}"
    if content =~ /^X-Spam-Status: Yes/
      log 'Mail is SPAM.'
      # exit 1
    end
  end
rescue Exception
  log "Exception scanning for SPAM: #{$!}"
end
log "Spam check took: #{Time.now - spam_start}s"

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
rescue Exception
  log "Exception storing record: #{$!}"
  exit EX_TEMPFAIL
end

if prod_recipients.any?
  create_record('production', from, prod_recipients, content)
end

if beta_recipients.any?
  create_record('beta', from, beta_recipients, content)
end

if rest_recipients.any?
  require 'bundler/setup'
  require 'mail'
  log "Sending to rest: #{from} => #{rest_recipients}"
  log content.lines.grep(/spam/i)
  mail = Mail.read_from_string(content)
  mail.smtp_envelope_from = from
  mail.smtp_envelope_to = rest_recipients
  mail.delivery_method :sendmail
  mail.deliver
end

log "Finished in #{Time.now - started_at}s"

exit 0
