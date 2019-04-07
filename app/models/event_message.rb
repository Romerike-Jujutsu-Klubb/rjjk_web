# frozen_string_literal: true

class EventMessage < ApplicationRecord
  module MessageType
    INFORMATION = 'INFORMATION'
    INVITATION = 'INVITATION'
    REMINDER = 'REMINDER'
    SIGNUP_CONFIRMATION = 'SIGNUP_CONFIRMATION'
    SIGNUP_REJECTION = 'SIGNUP_REJECTION'
  end

  module Templates
    SIGNUP_CONFIRMATION_SUBJECT = 'Bekreftelse av påmelding til [EVENT_NAME]'
    SIGNUP_CONFIRMATION = <<~TEXT
      Hei [EVENT_INVITEE_NAME]!

      Vi har mottatt din påmelding til [EVENT_NAME],
      og kan bekrefte at du har fått plass.

      Deltakeravgiften på kr 800,- betales på leiren med kort eller Vipps.
      Dette inkluderer lunsj og frukt på leiren.

      Har du noen spørsmål, så ta kontakt med oss på leir@jujutsu.no eller på telefon xxx xx xxx.

      Vi vil fortløpende oppdatere informasjon på [jujutsu.no]([EVENT_LINK]).
      --
      Med vennlig hilsen,
      Romerike Jujutsu Klubb
      https://jujutsu.no/
    TEXT
    SIGNUP_REJECTION_SUBJECT = 'Påmelding til [EVENT_NAME]'
    SIGNUP_REJECTION = <<~TEXT
      Hei [EVENT_INVITEE_NAME]!

      Vi har mottatt din påmelding til [EVENT_NAME],
      men må dessverre meddele at du ikke har fått plass pga. plassmangel.

      Vi har din kontaktinfo og vil ta kontakt hvis det skulle bli ledig plass.

      Har du noen spørsmål, så ta kontakt med oss på leir@jujutsu.no eller på telefon xxx xx xxx.

      --
      Med vennlig hilsen,
      Romerike Jujutsu Klubb
      https://jujutsu.no/
    TEXT
  end
  belongs_to :event
  has_many :event_invitee_messages, dependent: :restrict_with_exception

  validates :body, :event_id, :message_type, :subject, presence: true
  validates :message_type, uniqueness: {
    scope: :event_id,
    unless: ->(mt) { [MessageType::INFORMATION, MessageType::REMINDER].include? mt.message_type },
  }
end
