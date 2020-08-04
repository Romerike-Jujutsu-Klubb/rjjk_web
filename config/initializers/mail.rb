# frozen_string_literal: true

require 'mail'

class Mail::Message
  def store(recipient, tag:)
    user_id = case recipient
              when Member
                recipient.user.id
              when User
                recipient.id
              else
                recipient
              end
    html_part, plain_part = parts_by_type

    if (url_header = header['X-Email-URL'])
      email_url = JSON.parse(url_header.value)
    end
    user_email = header['X-User-Email']&.value
    title = header['X-Title']&.value
    timestamp = header['X-Message-Timestamp']&.value

    UserMessage.create! user_id: user_id, tag: tag, from: from.to_a,
                        subject: subject, email_url: email_url, user_email: user_email,
                        title: title, message_timestamp: timestamp,
                        html_body: html_part&.body&.decoded,
                        plain_body: plain_part&.body&.decoded
    UserMessageSenderJob.perform_later
  end

  def parts_by_type
    parts = body.parts.any? ? body.parts : [self]
    html_part = plain_part = nil
    parts.each do |part|
      case part.content_type
      when %r{text/html}
        html_part = part
      when %r{text/plain}
        plain_part = part
      else
        raise "Unknown content type: #{part.content_type.inspect}"
      end
    end
    [html_part, plain_part]
  end
end

delivery_method = Rails.application.config.action_mailer.delivery_method
Rails.logger.info "Sending email using: #{delivery_method.inspect}"
if delivery_method == :smtp
  smtp_settings = Rails.application.config.action_mailer.smtp_settings
  Rails.logger.info <<~MSG
    Sending email using SMTP server: #{smtp_settings[:address]} user: #{smtp_settings[:user_name]}
  MSG
end
