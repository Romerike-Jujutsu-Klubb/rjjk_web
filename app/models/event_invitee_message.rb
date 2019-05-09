# frozen_string_literal: true

class EventInviteeMessage < ApplicationRecord
  module MessageType
    SIGNUP_CONFIRMATION = 'SIGNUP_CONFIRMATION'
    SIGNUP_REJECTION = 'SIGNUP_REJECTION'
  end

  belongs_to :event_invitee

  validates :body, :event_invitee, :event_invitee_id, :message_type, :subject, presence: true
  validates :event_invitee_id, uniqueness: { scope: :event_message_id, if: :event_message_id }

  def initialize(*args)
    super
    return if subject.present? && body.present?
    return unless message_type

    if (event_message = event_invitee.event.event_messages.find_by(message_type: message_type))
      self.subject ||= event_message.subject
      self.body ||= event_message.body
    elsif EventMessage::Templates.const_defined?(message_type)
      self.subject ||= EventMessage::Templates.const_get("#{message_type}_SUBJECT")
      self.body ||= EventMessage::Templates.const_get(message_type)
    elsif message_type == EventMessage::MessageType::INVITATION
      self.subject ||= "Invitasjon til #{event_invitee.event.name}"
      self.body ||= event_invitee.event.description
    end

    self.subject = event_invitee.replace_markers(subject)
    self.body = event_invitee.replace_markers(body)
  end
end
