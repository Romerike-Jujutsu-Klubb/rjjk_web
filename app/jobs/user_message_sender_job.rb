# frozen_string_literal: true

class UserMessageSenderJob < ApplicationJob
  SHORT_STORAGE_TAGS = %i[attendance_change attendance_summary].freeze

  queue_as :default

  def perform
    messages = nil
    UserMessage.transaction(requires_new: true) do
      messages = UserMessage.lock.where(sent_at: nil, read_at: nil).order(:created_at).each do |um|
        # FIXME(uwe): Notify by push message if possible, or SMS?
        next if um.user.emails.empty?

        UserMessageMailer.send_message(um).deliver_now
        um.update! sent_at: Time.current
      rescue => e
        ExceptionNotifier.notify_exception(e)
        raise e
      end
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
