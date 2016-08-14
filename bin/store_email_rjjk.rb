#!/usr/bin/env ruby

started_at = Time.now

ENV['RAILS_ENV'] = 'email'

# FIXME(uwe): Why this setup?!  Remove observers!
Dir.chdir File.dirname(File.dirname(__FILE__))
require 'bundler'
require 'bundler/setup'
require 'active_support/core_ext/module/concerning'
require 'rails/observers/active_model/observing'
require 'rails/observers/activerecord/observer'
# EMXIF

require_relative '../config/environment'

Rails.logger.debug "ARGV: #{ARGV}"

from = ARGV[0]
to = ARGV[1..-1]

Rails.logger.debug "From: #{from}"
Rails.logger.debug "To: #{to}"

content = $stdin.read
# mail = Mail.read_from_string(content)

INSPECT_DIR = '/var/spool/filter'
SENDMAIL = '/usr/sbin/sendmail -G -i' # NEVER NEVER NEVER use "-t" here.

# Exit codes from <sysexits.h>
EX_TEMPFAIL = 75
EX_UNAVAILABLE = 69

# Clean up when done or when aborting.
# trap(0, 1, 2, 3, 15){"rm -f in.$$"}

begin
  require 'open3'
  Rails.logger.info 'Checking Spamassassin'
  Open3.popen3('spamassassin') do |stdin, stdout, stderr, wait_thr|
    Rails.logger.info "Spamassassin: send content to process"
    stdin << content
    Rails.logger.info "Spamassassin: close stdin"
    stdin.close
    Rails.logger.info "Spamassassin: read stdout"
    content = stdout.read
    Rails.logger.info "Spamassassin: #{content}"
    Rails.logger.info "Spamassassin: read stderr"
    Rails.logger.info "Spamassassin: #{stderr.read}"
    Rails.logger.info "Spamassassin: finish process"
    exit_status = wait_thr.value # Process::Status object returned.
    Rails.logger.info "Spamassassin reported: #{exit_status.inspect}"
    if content =~ /^X-Spam-Status: Yes/
      Rails.logger.info 'Mail is SPAM.'
      # exit 1
    end
  end
rescue Exception
  Rails.logger.error "Exception scanning for SPAM: #{$!}"
end

prod_recipients = to.grep /@jujutsu.no/
beta_recipients = to.grep /@beta.jujutsu.no/
rest_recipients = to - prod_recipients - beta_recipients

if prod_recipients.any?
  prod_content = content.prepend <<EOF
X-Envelope-From: #{from}
X-Envelope-To: #{prod_recipients.join(', ')}
EOF
  ENV['RAILS_ENV'] = Rails.env = 'production'
  RawIncomingEmail.establish_connection(Rails.env)
  RawIncomingEmail.create content: prod_content
end

if beta_recipients.any?
  beta_content = content.prepend <<EOF
X-Envelope-From: #{from}
X-Envelope-To: #{beta_recipients.join(', ')}
EOF
  ENV['RAILS_ENV'] = Rails.env = 'beta'
  RawIncomingEmail.establish_connection(Rails.env)
  RawIncomingEmail.create content: beta_content
end

if rest_recipients.any?
  Rails.logger.info "Sending to rest: #{from} => #{rest_recipients}"
  Rails.logger.info content.lines.grep(/spam/i)
  mail = Mail.read_from_string(content)
  mail.smtp_envelope_from = from
  mail.smtp_envelope_to = rest_recipients
  mail.delivery_method :sendmail
  mail.deliver
end

Rails.logger.info "Finished after #{Time.now - started_at}s"

exit 0
