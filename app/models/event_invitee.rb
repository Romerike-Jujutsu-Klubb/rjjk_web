# frozen_string_literal: true

class EventInvitee < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true

  has_one :invitation, -> { where("message_type = '#{EventMessage::MessageType::INVITATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_confirmation,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_rejection,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy

  has_many :event_invitee_messages, dependent: :destroy

  validates :event, :event_id, :name, presence: true
  validates :email, presence: { unless: :phone }, uniqueness: { scope: :event_id }
  validates :phone, presence: { unless: :email }
  validates :user_id, uniqueness: { scope: :event_id, allow_nil: true }
  validates :will_work, inclusion: { in: [nil, false], if: proc { |r| r.will_attend == false } }

  before_validation do
    if user
      self.name ||= user.name
      self.email ||= user.contact_email
      self.phone ||= user.contact_phone
      self.organization ||= 'Romerike Jujutsu Klubb' if user.member
    elsif security_token.blank?
      self.security_token = SecureRandom.base58(4)
    end
  end

  def name
    user&.name || super
  end

  def email
    user&.contact_email || super
  end

  def phone
    user&.contact_phone || super
  end

  def confirmed?
    signup_confirmation&.ready_at
  end

  def locale
    user&.locale || :nb
  end

  def security_token_matches(token)
    token == security_token || security_token.blank?
  end
end
