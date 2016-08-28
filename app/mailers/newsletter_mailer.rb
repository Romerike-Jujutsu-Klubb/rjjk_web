# frozen_string_literal: true
class NewsletterMailer < ApplicationMailer
  default from: if Rails.env.production?
                  '"Romerike Jujutsu Klubb" <post@jujutsu.no>'
                else
                  "#{Rails.env}@jujutsu.no"
                end

  def event_invitation(event, email)
    @event = event
    @email = email
    @title = event.name
    @email_url = { controller: :events, action: :show, id: @event.id }
    @user_email = @email
    @timestamp = event.start_at
    @email_end_at = event.end_at
    mail to: @email, subject: "Invitasjon til #{@event.name}"
  end

  def newsletter(news_item, member)
    @news_item = news_item
    @user_email = member.user&.email
    @timestamp = @news_item.updated_at.to_date
    @email_url = { controller: :news, action: :show, id: @news_item.id }
    mail to: member.email, subject: @news_item.title
  end

  def event_invitee_message(event_invitee_message)
    @event_invitee_message = event_invitee_message
    @event_invitee = event_invitee_message.event_invitee
    @email = @event_invitee.email
    @title = @subject = event_invitee_message.subject
    @email_url = { controller: :event_invitee_messages, action: :show, id: @event_invitee_message.id }
    @timestamp = @event_invitee.event.start_at
    @email_end_at = @event_invitee.event.end_at
    @body = event_invitee_message.body

    mail(to: @event_invitee.email, subject: @subject,
        bcc: 'Uwe Kubosch <uwe@kubosch.no>') do |format|
      format.html do
        layout = event_invitee_message.event_invitee.user_id ? false : 'email'
        render layout: layout
      end
      format.text { render }
    end
  end
end
