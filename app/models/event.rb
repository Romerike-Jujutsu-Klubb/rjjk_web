# frozen_string_literal: true

class Event < ApplicationRecord
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

  before_validation do |r|
    r.description = nil if r.description.blank?
    if r.invitees.nil? || r.invitees.blank?
      r.invitees = nil
    else
      r.invitees = r.invitees.gsub(/^\s+/, '')
      r.invitees = r.invitees.gsub(/\s+$/, '')
      r.invitees = r.invitees.gsub(/\s+/, ' ')
      r.invitees = r.invitees.split(/\s*,\s*/).sort_by(&:upcase).join(",\n") + "\n"
    end
  end

  validates :name, :start_at, presence: true

  before_update do |r|
    if r.invitees.present?
      r.invitees = r.invitees.gsub(/^\s+/, '')
      r.invitees = r.invitees.gsub(/\s+$/, '')
      r.invitees = r.invitees.gsub(/\s+/, ' ')
      r.invitees = r.invitees.split(/\s*,\s*/).sort_by(&:upcase).join(",\n") + "\n"
      r.invitees.split(/\s*,\s*/).each do |inv|
        if inv =~ /^(.*)\s*<(.*@.*)>$/
          name = Regexp.last_match(1)
          email = Regexp.last_match(2)
        elsif inv =~ /^(.*@.*)$/
          name = Regexp.last_match(1)
          email = Regexp.last_match(1)
        else
          name = inv
          email = inv
        end
        event_invitees.create name: name, email: email
      end
      r.invitees = nil
    end
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

  def invited_users
    users
  end

  def confirmed_users
    attending_invitees.select(&:confirmed?).map(&:user)
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
    paragraphs&.[](1..-1)
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
