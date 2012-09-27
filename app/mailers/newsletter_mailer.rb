class NewsletterMailer < ActionMailer::Base
  helper :mailer
  default from: '"Romerike Jujutsu Klubb" <post@jujutsu.no>'

  def event_invitation(event, email)
    @event = event
    @email = email

    mail to: Rails.env == 'production' ? @email : 'Uwe Kubosch <uwe@kubosch.no>',
         subject: "Invitasjon til #{@event.name}"
  end

  def newsletter(news_item, user)
    @news_item = news_item
    @user = user

    mail to: "uwe@kubosch.no"
  end

  def event_invitee_message(event_invitee, email, subject, body)
    @event_invitee = event_invitee
    @email = email
    @subject = subject
    @body = body

    mail to: Rails.env == 'production' ? @email : 'Uwe Kubosch <uwe@kubosch.no>',
         subject: subject
  end

end
