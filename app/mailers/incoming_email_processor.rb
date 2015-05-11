require 'mail'

class IncomingEmailProcessor
  RECIPIENTS = {
      kasserer: {name: 'Kasia Krohn', email: 'kasiakrohn@gmail.com'},
      materialforvalter: {name: 'Tommy Musaus', email: 'tommy.musaus@hellvikhus.no'},
      medlem: {name: 'Svein Robert Rolijordet', email: 'srr@resvero.com'},
      post: {name: 'Svein Robert Rolijordet', email: 'srr@resvero.com'},
      test: {name: 'don Valentin', email: 'donv@kubosch.no'},
  }

  def self.forward_emails
    RawIncomingEmail.where(processed_at: nil).order(:created_at).each do |raw_email|
      logger.debug "Forward email (#{raw_email.id}):"
      logger.debug raw_email.content
      email = Mail.read_from_string(raw_email.content)
      logger.debug "to: #{email.to}"
      sent = false
      RECIPIENTS.each do |target, destination|
        sent = check_target(raw_email, email, target, destination)
        break if sent
      end
      break if sent
    end
  end

  def self.check_target(raw_email, email, target, destination)
    return false unless email.to && email.to.any?{|t| t =~ /#{target}@(beta.)?jujutsu.no/}
    logger.debug 'send!'
    recipient = Rails.env.production? ?
        %Q{"[RJJK][#{target.to_s.capitalize}] #{destination[:name]}" <#{destination[:email]}>} :
        %Q{"[RJJK][#{Rails.env.upcase}][#{target.to_s.capitalize}] #{destination[:name]} <#{destination[:email]}>" <uwe@kubosch.no>}
    outgoing_email = raw_email.content.
        gsub(/^To:(.*\b#{target}@(?:beta.)?jujutsu.no\b.*)\n/) { "To: #{recipient}\n" }
    logger.debug 'Outgoing message:'
    logger.debug outgoing_email
    if Rails.env.test?
      ActionMailer::Base.deliveries << Mail.read_from_string(outgoing_email)
    else
      Net::SMTP.start('mail.kubosch.no') do |smtp|
        response = smtp.send_message(outgoing_email, email.from[0], recipient)
        logger.debug "Response: #{response.inspect}"
        unless response.success?
          raise "Bad response sending email: #{response.status.inspect} #{response.string.inspect} #{response.inspect}"
        end
      end
    end
    raw_email.update! processed_at: Time.now
    return true
  rescue
    logger.error "Exception sending email: #{$!}"
    logger.error $!.backtrace.join("\n")
    false
  end
end
