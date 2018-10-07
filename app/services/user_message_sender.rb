# frozen_string_literal: true

class UserMessageSender
  SHORT_STORAGE_TAGS = %i[attendance_change attendance_summary].freeze

  def self.send
    UserMessage.where(sent_at: nil, read_at: nil).order(:created_at).each do |m|
      UserMessageMailer.send_message(m).deliver_now
      m.update! sent_at: Time.current
    end

    UserMessage
        .where('created_at < ?', 10.years.ago)
        .or(UserMessage.where('created_at < ?', 12.months.ago).where(tag: SHORT_STORAGE_TAGS))
        .order(:created_at)
        .limit(5)
        .each(&:destroy!)
  end
end
