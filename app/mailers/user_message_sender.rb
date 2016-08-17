# frozen_string_literal: true
class UserMessageSender
  def self.send
    UserMessage.where(sent_at: nil, read_at: nil).order(:created_at).each do |m|
      UserMessageMailer.send_message(m).deliver_now
      m.update_attributes! sent_at: Time.now
    end
  end
end
