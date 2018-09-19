# frozen_string_literal: true

class SendGridController < ApplicationController
  SPAM_DELETE_LIMIT = 6.0
  # Exit codes from <sysexits.h>
  EX_TEMPFAIL = 75
  EX_UNAVAILABLE = 69

  skip_before_action :verify_authenticity_token

  def receive
    started_at = Time.current

    envelope = JSON.parse(params[:envelope]).symbolize_keys
    logger.info "params[:envelope]: #{envelope.inspect}"

    from = envelope[:from]
    to = envelope[:to]

    logger.info "#{started_at.strftime('%F %T')} Got email From: #{from}, To: #{to}"

    if to == ['noreply@beta.jujutsu.no']
      logger.info "Ignore recipient: #{to}"
      return
    end

    content = params[:email]

    begin
      orig_mail = Mail.read_from_string(content)
      if (encoding = orig_mail.content_type_parameters&.[]('charset'))
        logger.info "Convert to #{encoding.inspect}"
        content.force_encoding(encoding)
      end
    rescue => e
      logger.info "Exception setting encoding: #{e}"
    end

    if content.size <= 512_000
      mail_is_spam = nil
    else
      logger.info "Large message: #{content.size} bytes.  Skipping spam detection."
      mail_is_spam = 'LARGE'
    end
    mail = orig_mail

    prod_recipients = to.grep(/@([a-z0-9]+\.)?jujutsu.no/i)
    create_record('production', from, prod_recipients, content) if prod_recipients.any?

    rest_recipients = to - prod_recipients
    if rest_recipients.any?
      logger.info "Sending to rest: #{from} => #{rest_recipients}"

      begin
        logger.info content.lines.grep(/spam|^\s+\*/i)
      rescue Exception => e # rubocop: disable Lint/RescueException
        logger.error "Exception logging spam lines: #{e}"
        logger.error "Content Encoding: #{content.encoding}"
      end

      begin
        mail['X-Spam-My-Status'] = mail['X-Spam-Status']&.value
        mail.smtp_envelope_from = from
        mail.smtp_envelope_to = rest_recipients
        mail.delivery_method Rails.configuration.action_mailer.delivery_method,
            Rails.configuration.action_mailer.smtp_settings
        mail.deliver

        # ActionMailer::Base.mail(from: from, to: rest_recipients, subject: mail.subject, body: "test").deliver

        logger.info "\nDelivered OK to #{rest_recipients}"
      rescue => e
        logger.info "Exception sending email: #{e.class} #{e}"
        logger.info e.backtrace.join("\n")
        logger.info "Discarding spam message: #{mail&.subject}" if mail_is_spam
        return
      end
    end

    finished_at = Time.current
    logger.info "\n#{finished_at.strftime('%F %T')} Finished in #{finished_at - started_at}s\n\n"
  end

  def delivered; end

  private

  def safe_subject(subject, mail_is_spam, spam_score)
    ss = subject.to_s.gsub(/^((Fwd|Re|Sv):\s*)+/i, '').gsub(%r{[ \t:/\\\{\}`'"!]}, '_')
        .gsub(/_+/, '_')[0..100]
    @now_str ||= Time.current.strftime('%F_%T')
    spam_marker =
        case mail_is_spam
        when true
          '[SPAM]'
        when false
          '_____'
        when nil
          '?????'
        else
          "[#{mail_is_spam}]"
        end
    subject = "mail_#{@now_str}_#{spam_marker}"
    subject += "[#{spam_score}]" if spam_score
    subject += "_#{ss}"
    subject
  end

  def create_record(env, from, recipients, content)
    log "Storing in #{env} to: #{from} => #{recipients}"

    content_with_envelope = <<~HEADERS + content
      X-Envelope-From: #{from}
      X-Envelope-To: #{recipients.join(', ')}
    HEADERS

    RawIncomingEmail.create content: content_with_envelope
  rescue Exception => e # rubocop: disable Lint/RescueException
    log "Exception storing record: #{e}"
    render status: :internal_server_error
  end
end
