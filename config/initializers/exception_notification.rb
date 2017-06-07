# frozen_string_literal: true

env_prefix = ("#{Rails.env}." unless Rails.env.production?)
Rails.application.config.middleware.use ExceptionNotification::Rack,
    ignore_exceptions: [],
    email: {
        email_prefix: "[RJJK]#{"[#{Rails.env.upcase}]" unless Rails.env.production?} ",
        sender_address:
            "\"RJJK #{Rails.env.upcase} Exception Notifier\" <noreply@#{env_prefix}jujutsu.no>",
        exception_recipients: %w[uwe@kubosch.no],
    }
