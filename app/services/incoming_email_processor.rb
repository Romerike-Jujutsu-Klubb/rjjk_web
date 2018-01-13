# frozen_string_literal: true

require 'mail'

class IncomingEmailProcessor
  TARGETS = {
    kasserer: { name: 'Kasia Krohn', email: 'kasiakrohn@gmail.com' },
    materialforvalter: { name: 'Tommy Musaus', email: 'tommy.musaus@hellvikhus.no' },
    medlem: { name: 'Svein Robert Rolijordet', email: 'srr@resvero.com' },
    post: { name: 'Svein Robert Rolijordet', email: 'srr@resvero.com' },
    styret: AnnualMeeting.board_contacts,
    test: { name: 'don Valentin', email: 'donv@kubosch.no' },
    web: { name: 'Uwe Kubosch', email: 'uwe@kubosch.no' },
  }.freeze
  ENV_STR = Rails.env.production? ? nil : Rails.env.upcase
  DOMAIN = "#{"#{Rails.env}." unless Rails.env.production? || Rails.env.test?}jujutsu.no"
  PREFIX_PATTERN = '(\b(?:Re|Fwd):\s*)'

  def self.forward_emails
    RawIncomingEmail.where(processed_at: nil, postponed_at: nil)
        .order(:created_at).limit(5).each do |raw_email|
      logger.info "Forward email (#{raw_email.id}):"
      logger.debug raw_email.content
      email = Mail.read_from_string(raw_email.content)
      logger.debug "email.header['X-Envelope-From']: #{email.header['X-Envelope-From'].inspect}"
      logger.debug "email.header['X-Envelope-To']: #{email.header['X-Envelope-To'].inspect}"
      logger.debug "to: #{email.to.inspect}"
      logger.debug "smtp_envelope_to: #{email.smtp_envelope_to.inspect}"
      logger.debug "cc: #{email.cc}"
      logger.debug "bcc: #{email.bcc}"
      sent = false
      postponed = false

      sender = (begin
                  email.header['X-Envelope-From']&.to_s
                rescue
                  nil
                end) || email.from&.first
      logger.debug "sender: #{sender.inspect}"
      next postpone_email(raw_email) unless sender

      original_recipients = email.header['X-Envelope-To'].try(:to_s).try(:split, ', ') ||
          email.to || []
      logger.debug "original_recipients: #{original_recipients.inspect}"
      tags = []
      if ENV_STR
        tags << ENV_STR
        tags << 'RJJK'
      end

      # FIXME(uwe): Separate sending to each list with subject and reply_to
      new_recipients = original_recipients.map do |r|
        if r =~ /^(.*)@#{DOMAIN}$/
          target = Regexp.last_match(1).downcase.to_sym
          if (recipient = TARGETS[target])
            if recipient.is_a?(Array)
              logger.debug "Found list: #{target}"
              list = recipient
              tags << 'RJJK'
              tags << target.to_s.capitalize
              email.reply_to = "#{target}@#{DOMAIN}"
            else
              logger.debug "Found target: #{target}"
              list = [recipient]
            end
            list.map { |l| l[:email] }
          else
            logger.error "Unknown incoming email target: #{target.inspect}"
            postponed = true
            nil
          end
        else
          logger.error "Unexpected incoming email recipient: #{r.inspect}"
          postponed = true
          nil
        end
      end.flatten.compact.uniq
      logger.info "new_recipients: #{new_recipients.inspect}"

      if new_recipients.any?
        email.subject = prefix_subject(email.subject, tags)
        email.smtp_envelope_from = sender
        email.smtp_envelope_to =
            (Rails.env.production? || Rails.env.test? ? new_recipients : 'uwe@kubosch.no')
        email.delivery_method(Rails.env.test? ? :test : :sendmail)
        begin
          email.deliver
          sent = true
        rescue => e
          logger.error "Exception delivering incoming email: #{e.class} #{e}"
          logger.error e.backtrace.join("\n")
          postponed = true
        end
      else
        logger.error 'No recipients found.'
        postponed = true
      end

      if sent
        logger.info 'Mail processed OK!'
        raw_email.update! processed_at: Time.current
      end
      postpone_email(raw_email) if postponed
    end
  end

  def self.prefix_subject(subject, tags)
    subject = subject.to_s.dup
    subject.gsub!(/\[[^\]]*\]\s*/, '')
    subject.gsub!(/#{PREFIX_PATTERN * 2}+/, '\1')
    subject.prepend("#{tags.uniq.map { |t| "[#{t}]" }.join} ") if tags.any?
    subject
  end

  def self.postpone_email(raw_email)
    logger.info 'Mail postponed.'
    raw_email.update! postponed_at: Time.current
  end
end
