# frozen_string_literal: true

class EventInvitee < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  scope :for_user, ->(user_id) { where user_id: user_id }

  belongs_to :event
  belongs_to :user # FIXME(uwe): Set column user_id NOT NULL

  has_one :invitation, -> { where("message_type = '#{EventMessage::MessageType::INVITATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_confirmation,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_rejection,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy

  has_many :event_invitee_messages, dependent: :destroy

  # FIXME(uwe): Remove contact info (email, phone, address) when all invitees are users
  validates :event, :event_id, :name, presence: true
  validates :email, presence: { unless: :phone }
  validates :phone, presence: { unless: :email }
  validates :user_id, uniqueness: { scope: :event_id }
  validates :will_work, inclusion: { in: [nil, false], if: proc { |r| r.will_attend == false } }

  before_validation do
    if user
      self.name ||= user.name
      self.email ||= user.contact_email
      self.phone ||= user.contact_phone
      self.organization ||= 'Romerike Jujutsu Klubb' if user.member
    elsif security_token.blank?
      # FIXME(uwe): Remove all use of `security_token` and use `User` security instead.
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

  def rejected?
    signup_rejection&.ready_at
  end

  def locale
    user&.locale || :nb
  end

  def security_token_matches(token)
    token == security_token || security_token.blank?
  end

  def replace_markers(string)
    string
        .gsub('[EVENT_NAME]', event.name)
        .gsub('[EVENT_LINK]',
            Rails.application.routes.url_helpers.event_url(event.id, security_token: security_token))
        .gsub('[EVENT_INVITEE_NAME]', name)
        .gsub('[EVENT_REGISTRATION_LINK]', I18n.with_locale(:nb) { registration_link })
  end

  def registration_link
    link_to(I18n.t(:registration_link),
        Rails.application.routes.url_helpers.event_invitee_user_url(id, security_token: security_token))
  end
end
