# frozen_string_literal: true

class EventMailer < ApplicationMailer
  default from: if Rails.env.production?
                  '"Romerike Jujutsu Klubb" <leir@jujutsu.no>'
                else
                  "#{Rails.env}@jujutsu.no"
                end

  def registration_confirmation(event_registration)
    @event_registration = event_registration
    @email = event_registration.email
    @title = event_registration.event.name
    @email_url = { controller: :event_registration, action: :show, id: @event_registration.id }
    @user_email = @email
    @timestamp = event_registration.event.start_at
    @email_end_at = event_registration.event.end_at
    mail to: @email, subject: "Bekreftelse av påmelding til #{@event_registration.event.name}"
  end

  def event_invitee_message(event_invitee_message)
    @event_invitee_message = event_invitee_message
    @event_invitee = event_invitee_message.event_invitee
    @email = @event_invitee.email
    @title = @subject = event_invitee_message.subject
    @email_url = { controller: :event_invitee_messages, action: :show,
                   id: @event_invitee_message.id }
    @timestamp = @event_invitee.event.start_at
    @email_end_at = @event_invitee.event.end_at
    @body = event_invitee_message.body

    mail to: @event_invitee.email, subject: @subject, bcc: 'Uwe Kubosch <uwe@kubosch.no>'
  end
end
