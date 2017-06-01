# frozen_string_literal: true

class EventMessage < ApplicationRecord
  module MessageType
    INFORMATION = 'INFORMATION'
    INVITATION = 'INVITATION'
    REMINDER = 'REMINDER'
  end

  belongs_to :event
  has_many :event_invitee_messages

  validates :body, :event_id, :message_type, :subject, presence: true
  validates :message_type, uniqueness: { scope: :event_id,
                          if: proc { |mt| mt.message_type == MessageType::INVITATION } }
end
