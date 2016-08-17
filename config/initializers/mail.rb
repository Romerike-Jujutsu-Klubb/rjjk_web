# frozen_string_literal: true
require 'mail'

class Mail::Message
  def store(user, tag: nil)
    if user.is_a?(Member)
      user.create_corresponding_user! if user.user_id.nil?
      user_id = user.user_id
    elsif user.is_a?(User)
      user_id = user.id
    else
      user_id = user
    end
    parts =
        if body.parts.any?
          body.parts
        else
          [self]
        end
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

    email_url = JSON.load(header['X-Email-URL']&.value)
    user_email = header['X-User-Email']&.value
    title = header['X-Title']&.value
    timestamp = header['X-Message-Timestamp']&.value

    UserMessage.create! user_id: user_id, tag: tag, from: from,
        subject: subject, email_url: email_url, user_email: user_email,
        title: title, message_timestamp: timestamp,
        html_body: html_part&.body&.decoded,
        plain_body: plain_part&.body&.decoded
  end
end
