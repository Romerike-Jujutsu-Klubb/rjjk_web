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

      Deltakeravgiften på kr 800,- kan betales til konto 7035.05.37706.
      Merk betalingen med "[EVENT_NAME]".

      Har du noen spørsmål, så ta kontakt med Svein Robert på medlem@jujutsu.no eller på telefon 975 34 766.

      --
      Med vennlig hilsen,
      Uwe Kubosch
      Romerike Jujutsu Klubb
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
