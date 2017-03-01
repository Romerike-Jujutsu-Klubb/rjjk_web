#!/usr/bin/env ruby
# frozen_string_literal: true
# rubocop: disable Rails/TimeZone

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

def safe_subject(subject, mail_is_spam, spam_score)
  ss = subject.to_s.gsub(/^((Fwd|Re|Sv):\s*)+/i, '').gsub(%r{[ :/\\\{\}`'"!]}, '_')
      .gsub(/_+/, '_')[0..100]
  @now_str ||= Time.now.strftime('%F_%T')
  spam_marker = mail_is_spam ? '[SPAM]' : mail_is_spam == 'LARGE' ? '[LARGE]' : '_____'
  subject = "mail_#{@now_str}_#{spam_marker}"
  subject += "[#{spam_score}]" if spam_score
  subject += "_#{ss}"
  subject
end

begin
  require 'bundler/setup'
  require 'mail'
  orig_mail = Mail.read_from_string(content)
  if (encoding = orig_mail.content_type_parameters['charset'])
    log "Convert to #{encoding.inspect}"
    content.force_encoding(encoding)
  end
rescue => e
  log "Exception setting encoding: #{e}"
end

# Exit codes from <sysexits.h>
EX_TEMPFAIL = 75
EX_UNAVAILABLE = 69

def check_spam(content, mail)
  begin
    spam_start = Time.now
    mail_is_spam = nil
    spam_score = nil
    require 'open3'
    log 'Checking Spamassassin'
    Open3.popen3('spamc') do |stdin, stdout, stderr, wait_thr|
      stdin << content
      stdin.close
      content = stdout.read
      mail = Mail.read_from_string(content)
      if (encoding = mail.content_type_parameters['charset'])
        content.force_encoding(encoding)
      end
      log "Spamassassin: #{content}"
      log "Spamassassin: #{stderr.read}"
      exit_status = wait_thr.value # Process::Status object returned.
      spam_status_header = mail['X-Spam-Status']&.value
      log "Spamassassin reported: #{exit_status.inspect} #{spam_status_header.inspect}"
      if /^(?<spam_status>Yes|No), score=(?<spam_score>-?\d+\.\d+)/ =~ spam_status_header
        if (mail_is_spam = (spam_status == 'Yes'))
          log "Mail is SPAM: #{spam_score}"
          if spam_score.to_f >= 7.5
            log 'Discarding the email.'
            exit 0
          end
        end
      else
        log "Spam status mismatch: #{spam_status_header.inspect}"
      end
    end
  rescue SystemExit
    raise
  rescue Exception => e # rubocop: disable Lint/RescueException
    log "Exception scanning for SPAM: #{e}\n#{e.backtrace.join("\n")}"
  end
  log "Spam check took: #{Time.now - spam_start}s"
  [content, mail, mail_is_spam, spam_score]
end

if content.size <= 512_000
  content, mail, mail_is_spam, spam_score = check_spam(content, orig_mail)
else
  log "Large message: #{content.size} bytes.  Skipping spam detection."
  mail = orig_mail
  mail_is_spam = 'LARGE'
  spam_score = nil
end

File.write(safe_subject(orig_mail.subject, mail_is_spam, spam_score), content)

prod_recipients = to.grep(/@jujutsu.no/)
beta_recipients = to.grep(/@beta.jujutsu.no/)
rest_recipients = to - prod_recipients - beta_recipients

def create_record(env, from, recipients, content)
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
  log "Sending to rest: #{from} => #{rest_recipients}"
  begin
    log content.lines.grep(/spam|^\s+\*/i)
  rescue Exception => e # rubocop: disable Lint/RescueException
    puts e
    log "Exception logging spam lines: #{e}"
    log "Content Encoding: #{content.encoding}"
  end
  begin
    mail.smtp_envelope_from = from
    mail.smtp_envelope_to = rest_recipients
    mail.delivery_method :sendmail
    mail.deliver
    log "\nDelivered OK to #{rest_recipients}"
  rescue => e
    log "Exception sending email: #{e.class} #{e}"
    log e.backtrace.join("\n")
    if mail_is_spam
      log "Discarding spam message: #{mail&.subject}"
    else
      File.write("bad_email-#{@now_str}", content)
    end
    exit 1
  end
end

finished_at = Time.now
log "\n#{finished_at.strftime('%F %T')} Finished in #{finished_at - started_at}s\n\n"

exit 0
# rubocop: enable Rails/TimeZone
