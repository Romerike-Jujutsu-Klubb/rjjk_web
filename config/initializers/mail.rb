# frozen_string_literal: true

require 'mail'

class Mail::Message
  def store(recipient, tag:)
    user_id = if recipient.is_a?(Member)
                recipient.user.id
              elsif recipient.is_a?(User)
                recipient.id
              else
                recipient
              end
    parts = body.parts.any? ? body.parts : [self]
    html_part = plain_part = nil
    parts.each do |part|
      if part.content_type =~ %r{text/html}
        html_part = part
      elsif part.content_type =~ %r{text/plain}
        plain_part = part
      else
        raise "Unknown content type: #{part.content_type.inspect}"
      end
    end

    if (url_header = header['X-Email-URL'])
      email_url = JSON.parse(url_header.value)
    end
    user_email = header['X-User-Email']&.value
    title = header['X-Title']&.value
    timestamp = header['X-Message-Timestamp']&.value

    UserMessage.create! user_id: user_id, tag: tag, from: from,
                        subject: subject, email_url: email_url, user_email: user_email,
                        title: title, message_timestamp: timestamp,
                        html_body: html_part&.body&.decoded,
                        plain_body: plain_part&.body&.decoded
    UserMessageSenderJob.perform_later
  end
end
