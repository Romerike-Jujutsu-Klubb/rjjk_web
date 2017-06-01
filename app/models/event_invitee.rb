# frozen_string_literal: true

class EventInvitee < ApplicationRecord
  belongs_to :event
  belongs_to :user
  has_one :invitation, -> { where("message_type = '#{EventMessage::MessageType::INVITATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_confirmation,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_rejection,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_many :event_invitee_messages, -> do
    where("message_type IS NULL OR message_type <> '#{EventMessage::MessageType::INVITATION}'")
  end, dependent: :destroy

  validates :event, :event_id, :name, :email, presence: true
  validates :user_id, uniqueness: { scope: :event_id, allow_nil: true }
  validates :will_work, inclusion: { in: [nil, false], if: proc { |r| r.will_attend == false } }

  before_create do
    if user
      self.name = user.name
      self.email = user.email
      self.organization = 'Romerike Jujutsu Klubb' if user.member
    end
  end

  def name
    user.try(:name) || super
  end

  def email
    user.try(:email) || super
  end
end
