# frozen_string_literal: true

class Event < ApplicationRecord
  scope :chronological, -> { order :start_at }

  has_one :invitation, class_name: 'EventMessage', dependent: :destroy

  has_many :attending_invitees, -> { where(will_attend: true) }, class_name: :EventInvitee
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

  def ingress
    description.try(:slice, %r{\A.*?(?:<br ?/><br ?/>|</p>|\Z)}im)
  end

  def body
    ingress = self.ingress
    description[ingress.size..-1] if ingress && description.size > ingress.size
  end

  delegate :size, to: :attending_invitees
end
