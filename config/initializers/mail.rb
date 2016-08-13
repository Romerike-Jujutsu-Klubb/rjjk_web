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
    parts = if body.parts.any?
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
    UserMessage.create! user_id: user_id, tag: tag, from: from,
        subject: subject, html_body: html_part&.body&.decoded,
        plain_body: plain_part&.body&.decoded
  end
end
