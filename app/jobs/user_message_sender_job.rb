# frozen_string_literal: true

class UserMessageSenderJob < ApplicationJob
  SHORT_STORAGE_TAGS = %i[attendance_change attendance_summary].freeze

  queue_as :default

  def perform
    messages = UserMessage.where(sent_at: nil, read_at: nil).order(:created_at).each do |m|
      UserMessageMailer.send_message(m).deliver_now
      m.update! sent_at: Time.current
    end

    return unless messages.any?

    UserMessage
        .where('created_at < ?', 10.years.ago)
        .or(UserMessage.where('created_at < ?', 12.months.ago).where(tag: SHORT_STORAGE_TAGS))
        .order(:created_at)
        .limit(5)
        .each(&:destroy!)
  end
end
