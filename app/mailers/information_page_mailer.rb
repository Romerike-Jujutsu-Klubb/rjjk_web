class InformationPageMailer < ActionMailer::Base
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no"

  def notify_outdated_pages(recipients, pages)
    @recipients = recipients
    @pages = pages
    mail to: Rails.env == 'production' ?
        recipients.map(&:email) : %Q{"#{recipients.map(&:first_name).join(' ')}" <uwe@kubosch.no>},
         subject: '[RJJK] Oppdatering av informasjonssider'
  end

  def send_weekly_page
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end
end
