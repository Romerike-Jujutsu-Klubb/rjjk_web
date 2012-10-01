# encoding: utf-8
class EventInviteeMessage < ActiveRecord::Base
  module MessageType
    SIGNUP_CONFIRMATION = 'SIGNUP_CONFIRMATION'
    SIGNUP_REJECTION = 'SIGNUP_REJECTION'
  end

  attr_accessible :body, :event_invitee, :event_invitee_id, :message_type, :ready_at, :sent_at, :subject

  belongs_to :event_invitee

  validates_presence_of :body, :event_invitee, :event_invitee_id, :message_type, :subject
  validates_uniqueness_of :event_invitee_id, :scope => :message_type

  def initialize(*args)
    super
    if message_type == MessageType::SIGNUP_CONFIRMATION
      self.subject ||= "Bekreftelse av påmelding #{event_invitee.event.name}"
      self.body ||= %Q{Hei #{event_invitee.name}!\n\nVi har mottatt din påmelding til #{event_invitee.event.name},
og kan bekrefte at du har fått plass.

Deltakeravgiften på kr 700,- kan betales til konto 7035.05.37706.
Merk betalingen med "#{event_invitee.event.name}".

Har du noen spørsmål, så ta kontakt med Uwe på uwe@kubosch.no eller på telefon 922 06 046.

--
Med vennlig hilsen,
Uwe Kubosch
Romerike Jujutsu Klubb
}
      elsif message_type == MessageType::SIGNUP_REJECTION
        self.subject ||= "Påmelding til #{event_invitee.event.name}"
        self.body ||= %Q{Hei #{event_invitee.name}!\n\nVi har mottatt din påmelding til #{event_invitee.event.name},
men må dessverre meddele at du ikke har fått plass pga. plassmangel.

Vi har din kontaktinfo og vil ta kontakt hvis det skulle bli ledig plass.

Har du noen spørsmål, så ta kontakt med Uwe på uwe@kubosch.no eller på telefon 922 06 046.

--
Med vennlig hilsen,
Uwe Kubosch
Romerike Jujutsu Klubb
}
    end
  end

end
