# frozen_string_literal: true

class EventInvitee < ApplicationRecord
  include ActionView::Helpers::UrlHelper

  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze
  INTERNAL_ORG = 'Romerike Jujutsu Klubb'

  scope :for_user, ->(user_id) { where user_id: user_id }

  belongs_to :event
  belongs_to :user

  has_one :invitation, -> do
    where("message_type = '#{EventMessage::MessageType::INVITATION}'")
        .order(:sent_at, :ready_at, :created_at).reverse_order
  end,
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_confirmation,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_rejection,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy

  has_many :event_invitee_messages, dependent: :destroy

  validates :event, :event_id, :name, presence: true
  validates :email, presence: { unless: ->(ei) { ei.phone.present? } },
      format: { with: EMAIL_REGEXP, allow_nil: true }
  validates :phone, presence: { unless: ->(ei) { ei.email.present? } }
  validates :user_id, uniqueness: { scope: :event_id, allow_nil: true }
  validates :will_work,
      inclusion: { in: [nil, false], if: proc { |r| r.event&.needs_helpers? && r.will_attend == false } }

  accepts_nested_attributes_for :user

  before_validation { self.organization ||= INTERNAL_ORG if user&.member }

  delegate :address, :locale, :name, to: :user, allow_nil: true

  def email
    user&.contact_email
  end

  def phone
    user&.contact_phone
  end

  def invited?
    invitation&.ready_at || confirmed? || rejected?
  end

  def confirmed?
    will_attend && signup_confirmation&.ready_at
  end

  def rejected?
    signup_rejection&.ready_at
  end

  def replace_markers(string)
    string.gsub!('[EVENT_NAME]', event.name) if event.name.present?
    string
        .gsub('[EVENT_LINK]',
            Rails.application.routes.url_helpers.event_url(event.id, key: user.security_token))
        .gsub('[EVENT_INVITEE_NAME]', name)
        .gsub('[EVENT_REGISTRATION_LINK]', registration_link)
  end

  def registration_link
    url = Rails.application.routes.url_helpers.event_registration_url(id, key: user.security_token)
    root_url = Rails.application.routes.url_helpers.root_url
    print_link = "#{I18n.t(:registration_link).chomp('.')}: #{link_to(root_url, root_url)}"
    print_span = "<span class='d-none d-print-inline'>#{print_link} .</span>"
    "#{link_to(I18n.t(:registration_link), url, class: 'd-print-none')}#{print_span}"
  end
end
