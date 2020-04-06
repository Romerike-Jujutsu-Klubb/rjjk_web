# frozen_string_literal: true

class Event < ApplicationRecord
  extend InheritenceBaseNaming

  scope :chronological, -> { order :start_at }
  scope :upcoming, -> { where 'DATE(COALESCE(end_at, start_at)) >= ?', Date.current }

  has_one :invitation, class_name: 'EventMessage', dependent: :destroy

  has_many :attending_invitees, -> { where(will_attend: true) }, class_name: :EventInvitee
  has_many :declined_invitees, -> { where(will_attend: false) }, class_name: :EventInvitee
  has_many :event_groups, dependent: :destroy
  has_many :event_invitees, dependent: :destroy
  has_many :event_messages, dependent: :destroy
  has_many :groups, through: :event_groups
  has_many :users, through: :event_invitees

  before_validation { |r| r.description = nil if r.description.blank? }

  validates :start_at, presence: true

  def self.types
    @types ||= Dir["#{__dir__}/*.rb"]
        .map { |f| /^class (?<clas>.*) < Event$/ =~ File.read(f) && clas.constantize }.compact
  end

  def self.type_name
    I18n.t(name.underscore, name)
  end

  def type_name
    self.class.type_name
  end

  def typed_title
    "#{type_name}#{": #{name}" if name.present?}"
  end

  delegate :size, to: :attending_invitees

  def needs_helpers?
    false
  end

  def public?
    true
  end

  def upcoming?
    (end_at || start_at).to_date >= Date.current
  end

  def publish_at
    [created_at, ((start_at - Time.current) / 2).seconds.ago].max
  end

  def expired?
    Time.current > expire_at
  end

  def expire_at
    (end_at || start_at) + 1.week
  end

  def summary
    ingress
  end

  def ingress
    paragraphs&.first
  end

  def invited
    event_invitees.select { |ei| ei.will_attend.nil? && ei.invitation&.sent_at }
  end

  def invited_users
    invited.map(&:user)
  end

  def registered
    attending_invitees.reject(&:confirmed?).reject(&:rejected?)
  end

  def confirmed
    attending_invitees.select(&:confirmed?)
  end

  def confirmed_users
    confirmed.map(&:user)
  end

  def attendees
    attending_invitees.map(&:user)
  end

  def declined_users
    declined_invitees.map(&:user)
  end

  def creator; end

  def title
    localized_name
  end

  def publication_state
    if [name, start_at].all?(&:present?)
      NewsItem::PublicationState::PUBLISHED
    else
      NewsItem::PublicationState::DRAFT
    end
  end

  def localized_name
    (I18n.locale == :nb ? name : name_en).presence || name.presence || name_en.presence || type_name
  end

  def body
    body_paragraphs = paragraphs&.[](1..-1)
    return if body_paragraphs.blank?

    body_paragraphs.join("\n\n")
  end

  def news_item_likes
    nil
  end

  private

  def paragraphs
    ((I18n.locale == :nb ? description : description_en.presence) || description)&.split(/\r?\n\r?\n/)
  end
end
