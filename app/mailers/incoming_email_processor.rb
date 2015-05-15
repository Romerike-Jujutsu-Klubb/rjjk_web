# encoding: utf-8
require 'mail'

class IncomingEmailProcessor
  RECIPIENTS = {
      kasserer: {name: 'Kasia Krohn', email: 'kasiakrohn@gmail.com'},
      materialforvalter: {name: 'Tommy Musaus', email: 'tommy.musaus@hellvikhus.no'},
      medlem: {name: 'Svein Robert Rolijordet', email: 'srr@resvero.com'},
      post: {name: 'Svein Robert Rolijordet', email: 'srr@resvero.com'},
      styret: [
          {name: 'Svein Robert Rolijordet', email: 'srr@resvero.com'},
          {name: 'Trond Evensen', email: 'trondevensen@icloud.com'},
          {name: 'Kasia Krohn', email: 'kasiakrohn@gmail.com'},
          {name: 'Torstein Resløkken', email: 'reslokken@gmail.com'},
          {name: 'Uwe Kubosch', email: 'uwe@kubosch.no'},
      ],
      test: {name: 'don Valentin', email: 'donv@kubosch.no'},
      web: {name: 'Uwe Kubosch', email: 'uwe@kubosch.no'},
  }

  def self.forward_emails
    RawIncomingEmail.where(processed_at: nil, postponed_at: nil).
        order(:created_at).limit(1).each do |raw_email|
      logger.debug "Forward email (#{raw_email.id}):"
      logger.debug raw_email.content
      email = Mail.read_from_string(raw_email.content)
      logger.debug "to: #{email.to}"
      logger.debug "cc: #{email.cc}"
      logger.debug "bcc: #{email.bcc}"
      sent = false
      RECIPIENTS.each do |target, destination|
        sent ||= check_target(raw_email, email, target, destination)
      end
      if sent
        logger.info 'Mail processed OK!'
        raw_email.update! processed_at: Time.now
      else
        logger.info 'Mail postponed.'
        raw_email.update! postponed_at: Time.now
      end
    end
  end

  # FIXME(uwe):  Manipulate and send the Mail object insetad of RawIncomingEmail
  def self.check_target(raw_email, email, target, destination)
    return false unless [email.to, email.cc, email.bcc].flatten.compact.
        any? { |t| t =~ /#{target}@(beta.)?jujutsu.no/i }
    logger.debug 'send!'
    if destination.is_a?(Array)
      destinations = destination
      subject = "[RJJK]#{"[#{Rails.env.upcase}]" unless Rails.env.production?}[#{target.to_s.capitalize}] #{email.subject}"
      reply_to = "#{target}@jujutsu.no"
    else
      destinations = [destination]
    end
    logger.debug destinations.inspect
    destinations.each do |destination|
      recipient = Rails.env.production? ?
          %Q{"[RJJK][#{target.to_s.capitalize}] #{destination[:name]}" <#{destination[:email]}>} :
          %Q{"[RJJK][#{Rails.env.upcase}][#{target.to_s.capitalize}] #{destination[:name]} <#{destination[:email]}>" <uwe@kubosch.no>}

      outgoing_email = raw_email.content.
          gsub(/^(To|Cc|Bcc):(.*\b#{target}@(?:beta.)?jujutsu.no\b.*)\n/i) { "#$1: #{recipient}\n" }
      if reply_to
        outgoing_email = outgoing_email.gsub(/^Reply-to:.*\n/, '')
        outgoing_email = outgoing_email.sub(/^From:/, "Reply-to: #{reply_to}\nFrom:")
      end
      if reply_to
        outgoing_email = outgoing_email.gsub(/^Subject:.*\n/, '')
        outgoing_email = outgoing_email.sub(/^From:/, "Subject: #{subject}\nFrom:")
      end

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
    end
    return true
  rescue
    logger.error "Exception sending email: #{$!}"
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
    false
  end
end
