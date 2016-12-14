# frozen_string_literal: true
class EventInviteeMessage < ActiveRecord::Base
  module MessageType
    SIGNUP_CONFIRMATION = 'SIGNUP_CONFIRMATION'
    SIGNUP_REJECTION = 'SIGNUP_REJECTION'
  end

  belongs_to :event_invitee

  validates :body, :event_invitee, :event_invitee_id, :message_type, :subject, presence: true
  validates :event_invitee_id, uniqueness: { scope: :message_type,
      if: proc { |eim| eim.message_type == EventMessage::MessageType::INVITATION } }
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
      self.body ||= <<~EOF
        Hei #{event_invitee.name}!\n\nVi har mottatt din påmelding til #{event_invitee.event.name},
        og kan bekrefte at du har fått plass.

        Deltakeravgiften på kr 800,- kan betales til konto 7035.05.37706.
        Merk betalingen med "#{event_invitee.event.name}".

        Har du noen spørsmål, så ta kontakt med Svein Robert på medlem@jujutsu.no eller på telefon 975 34 766.

        --
        Med vennlig hilsen,
        Uwe Kubosch
        Romerike Jujutsu Klubb
      EOF
    elsif message_type == MessageType::SIGNUP_REJECTION
      self.subject ||= "Påmelding til #{event_invitee.event.name}"
      self.body ||= <<~EOF
        Hei #{event_invitee.name}!\n\nVi har mottatt din påmelding til #{event_invitee.event.name},
        men må dessverre meddele at du ikke har fått plass pga. plassmangel.

        Vi har din kontaktinfo og vil ta kontakt hvis det skulle bli ledig plass.

        Har du noen spørsmål, så ta kontakt med Uwe på uwe@kubosch.no eller på telefon 922 06 046.

        --
        Med vennlig hilsen,
        Uwe Kubosch
        Romerike Jujutsu Klubb
      EOF
    end
  end
end
