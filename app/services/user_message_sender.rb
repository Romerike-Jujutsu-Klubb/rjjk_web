# frozen_string_literal: true

class UserMessageSender
  def self.send
    UserMessage.where(sent_at: nil, read_at: nil).order(:created_at).each do |m|
      UserMessageMailer.send_message(m).deliver_now
      m.update! sent_at: Time.current
    end
  end
end
