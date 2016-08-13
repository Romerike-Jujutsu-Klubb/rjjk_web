Rails.application.config.middleware.use ExceptionNotification::Rack,
    ignore_exceptions: [],
    email: {
        email_prefix: "[RJJK]#{"[#{Rails.env}]" unless Rails.env.production?} ",
        sender_address: "\"RJJK #{Rails.env} Exception Notifier\" <noreply-#{Rails.env}@jujutsu.no>",
        exception_recipients: %w{uwe@kubosch.no}
    }
