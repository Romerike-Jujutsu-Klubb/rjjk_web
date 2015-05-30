#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'email'
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
EX_UNAVAILABLE=69

# Clean up when done or when aborting.
# trap(0, 1, 2, 3, 15){"rm -f in.$$"}

prod_recipients = to.grep /@jujutsu.no/
beta_recipients = to.grep /@beta.jujutsu.no/
rest_recipients = to - prod_recipients - beta_recipients

if prod_recipients.any?
  prod_content = content.prepend <<EOF
X-Envelope-From: #{from}
X-Envelope-To: #{prod_recipients.join(', ')}
EOF
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
  mail = Mail.read_from_string(content)
  mail.smtp_envelope_from = from
  mail.smtp_envelope_to = rest_recipients
  mail.delivery_method :sendmail
  mail.deliver
end

exit 0
