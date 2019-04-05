# frozen_string_literal: true

class EventInviteeMessage < ApplicationRecord
  module MessageType
    SIGNUP_CONFIRMATION = 'SIGNUP_CONFIRMATION'
    SIGNUP_REJECTION = 'SIGNUP_REJECTION'
  end

  belongs_to :event_invitee

  validates :body, :event_invitee, :event_invitee_id, :message_type, :subject, presence: true
  validates :message_type, uniqueness: {
    scope: :event_invitee_id,
    if: proc { |eim| eim.message_type == EventMessage::MessageType::INVITATION },
  }
  validates :event_invitee_id, uniqueness: { scope: :event_message_id, if: :event_message_id }

  def initialize(*args)
    super
    if message_type == EventMessage::MessageType::INVITATION
      self.subject ||= "Invitasjon til #{event_invitee.event.name}"
      self.body ||= event_invitee.event.description.gsub(%r{<br />}, "\n")
          .gsub(%r{<p>(.*?)</p>}m, "\\1\n").gsub(%r{<a .*?>(.*?)</a>}, '\\1')
          .html_safe # rubocop: disable Rails/OutputSafety
    elsif message_type == MessageType::SIGNUP_CONFIRMATION
      self.subject ||= "Bekreftelse av påmelding #{event_invitee.event.name}"
      self.body ||=
          event_invitee.event.event_messages
              .find_by(message_type: EventMessage::MessageType::SIGNUP_CONFIRMATION)
      self.body ||= EventMessage::Templates.SIGNUP_CONFIRMATION(self)
    elsif message_type == MessageType::SIGNUP_REJECTION
      self.subject ||= "Påmelding til #{event_invitee.event.name}"
      self.body ||= <<~TEXT
        Hei #{event_invitee.name}!\n\nVi har mottatt din påmelding til #{event_invitee.event.name},
        men må dessverre meddele at du ikke har fått plass pga. plassmangel.

        Vi har din kontaktinfo og vil ta kontakt hvis det skulle bli ledig plass.

        Har du noen spørsmål, så ta kontakt med Uwe på uwe@kubosch.no eller på telefon 922 06 046.

        --
        Med vennlig hilsen,
        Uwe Kubosch
        Romerike Jujutsu Klubb
      TEXT
    end
  end
end
