class NewsletterMailer < ActionMailer::Base
  helper :application
  include MailerHelper

  default from: {
          'production' => '"Romerike Jujutsu Klubb" <post@jujutsu.no>',
          'beta' => 'beta@jujutsu.no',
          'test' => 'test@jujutsu.no',
          'development' => 'development@jujutsu.no',
      }[Rails.env]

  def event_invitation(event, email)
    @event = event
    @email = email

    mail to: Rails.env == 'production' ? @email : 'Uwe Kubosch <uwe@kubosch.no>',
        subject: "Invitasjon til #{@event.name}"
  end

  def newsletter(news_item, member)
    @news_item = news_item
    @user = member.user
    mail to: safe_email(member), subject: rjjk_prefix(@news_item.title)
  end

  def event_invitee_message(event_invitee_message)
    @event_invitee_message = event_invitee_message
    @event_invitee = event_invitee_message.event_invitee
    @email = @event_invitee.email
    @subject = event_invitee_message.subject
    @body = event_invitee_message.body

    mail to: safe_email(@event_invitee), subject: rjjk_prefix(@subject),
        bcc: 'Uwe Kubosch <uwe@kubosch.no>'
  end

end
