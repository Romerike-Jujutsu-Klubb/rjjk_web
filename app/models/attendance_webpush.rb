# frozen_string_literal: true

class AttendanceWebpush < ApplicationRecord
  belongs_to :member

  def self.push_all(title, body, except: nil, tag:, data: {})
    AttendanceWebpush.where.not(member_id: except).find_each do |subscription|
      logger.info "Notifying #{subscription.member.user.name}"
      Webpush.payload_send(**subscription.webpush_params(title, body, tag: tag, data: data))
    rescue => e
      logger.error e
      logger.error('Failed to send push msg.  Delete subscription.')
      subscription.destroy!
    end
  end

  def webpush_params(title, body, tag:, data:)
    params = {
      message: { title: title, body: body, tag: tag, data: data }.to_json,
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'mailto:web@jujutsu.no',
        public_key: ENV['VAPID_PUBLIC_KEY'],
        private_key: ENV['VAPID_PRIVATE_KEY'],
      },
      # ssl_timeout: 5, # value for Net::HTTP#ssl_timeout=, optional
      # open_timeout: 5, # value for Net::HTTP#open_timeout=, optional
      # read_timeout: 5, # value for Net::HTTP#read_timeout=, optional
    }
    logger.info params
    params
  end
end
