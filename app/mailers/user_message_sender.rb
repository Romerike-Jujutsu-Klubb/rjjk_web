class UserMessageSender
  def self.send
    UserMessage.where(sent_at: nil, read_at: nil).each do |m|
      begin
        UserMessageMailer.send_message(m).deliver_now
        m.update_attributes! sent_at: Time.now
      rescue => e
        raise if Rails.env.test?
        logger.error "Exception sending user message: #{m.inspect} #{e}"
        logger.error e.backtrace.join("\n")
        ExceptionNotifier.notify_exception(e)
      end
    end
  end
end
