# frozen_string_literal: true

class Event < ApplicationRecord
  HEADER = 'Arrangement'

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
    (I18n.locale == :nb ? name : name_en) || name
  end

  def body
    body_paragraphs = paragraphs&.[](1..-1)
    return if body_paragraphs.blank?

    body_paragraphs.join("\n\n")
  end

  delegate :size, to: :attending_invitees

  def news_item_likes
    nil
  end

  private

  def paragraphs
    ((I18n.locale == :nb ? description : description_en.presence) || description)&.split(/\r?\n\r?\n/)
  end
end

Dir["#{__dir__}/*.rb"].each do |f|
  require_dependency File.basename(f) if /class .* < Event/.match?(File.read(f))
end
