# frozen_string_literal: true

class PracticeNotificationsController < ApplicationController
  def index; end

  def subscribe
    json_dump = JSON.dump(params[:subscription].to_unsafe_hash)
    session[:subscription] = json_dump
    subscriptions << json_dump
    logger.info "Subscriptions: #{subscriptions.size}"
    head :ok
  end

  def push
    Webpush.payload_send webpush_params(fetch_subscription)
    subscriptions.dup.each do |encoded_subscription|
      decoded_subscription = JSON.parse(encoded_subscription).with_indifferent_access
      begin
        Webpush.payload_send webpush_params(decoded_subscription)
      rescue
        logger.error('Failed to send push msg.  Delete subscription.')
        subscriptions.delete(encoded_subscription)
      end
    end
    head :ok
  end

  # app.rb
  # Use the webpush gem API to deliver a push notiifcation merging
  # the message, subscription values, and vapid options
  post "/push" do
    Webpush.payload_send(
        message: params[:message],
        endpoint: params[:subscription][:endpoint],
        p256dh: params[:subscription][:keys][:p256dh],
        auth: params[:subscription][:keys][:auth],
        vapid: {
            subject: "mailto:sender@example.com",
            public_key: ENV['VAPID_PUBLIC_KEY'],
            private_key: ENV['VAPID_PRIVATE_KEY']
        },
        ssl_timeout: 5, # value for Net::HTTP#ssl_timeout=, optional
        open_timeout: 5, # value for Net::HTTP#open_timeout=, optional
        read_timeout: 5 # value for Net::HTTP#read_timeout=, optional
    )
  end

  private

  def webpush_params(subscription_params)
    message = "Hello world, the time is #{Time.zone.now}"
    endpoint = subscription_params[:endpoint]
    p256dh = subscription_params.dig(:keys, :p256dh)
    auth = subscription_params.dig(:keys, :auth)

    params = {
      message: message,
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: 'mailto:sender@example.com',
        public_key: ENV['VAPID_PUBLIC_KEY'],
        private_key: ENV['VAPID_PRIVATE_KEY'],
      },
    }
    logger.info params
    params
  end

  def fetch_subscription
    encoded_subscription = session.fetch(:subscription) do
      raise 'Cannot create notification: no :subscription in params or session'
    end
    JSON.parse(encoded_subscription).with_indifferent_access
  end
end
