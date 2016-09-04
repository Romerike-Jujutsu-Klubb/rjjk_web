# frozen_string_literal: true
class Event < ActiveRecord::Base
  scope :chronological, -> { order :start_at }

  has_many :event_invitees, dependent: :destroy
  has_many :attending_invitees, -> { where(will_attend: true) },
      class_name: EventInvitee
  has_many :event_messages, dependent: :destroy
  has_many :users, through: :event_invitees
  has_and_belongs_to_many :groups
  has_one :invitation, class_name: 'EventMessage'
  has_one :graduation # optional

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

  validates :start_at, presence: true

  before_update do |r|
    unless r.invitees.blank?
      r.invitees = r.invitees.gsub(/^\s+/, '')
      r.invitees = r.invitees.gsub(/\s+$/, '')
      r.invitees = r.invitees.gsub(/\s+/, ' ')
      r.invitees = r.invitees.split(/\s*,\s*/).sort_by(&:upcase).join(",\n") + "\n"
      r.invitees.split(/\s*,\s*/).each do |inv|
        if inv =~ /^(.*) <(.*@.*)>$/
          name = $1
          email = $2
        elsif inv =~ /^(.*@.*)$/
          name = $1
          email = $1
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
