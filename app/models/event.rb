class Event < ActiveRecord::Base
  scope :chronological, :order => 'start_at'

  has_many :event_invitees, :order => :name, :dependent => :destroy
  has_many :event_messages, :dependent => :destroy
  has_many :users, :through => :event_invitees
  has_and_belongs_to_many :groups
  has_one :invitation, :class_name => 'EventMessage'
  has_one :graduation # optional

  before_validation do |r|
    r.description = nil if r.description.blank?
    if r.invitees.nil? || r.invitees.blank?
      r.invitees = nil
    else
      r.invitees = r.invitees.gsub /^\s+/, ''
      r.invitees = r.invitees.gsub /\s+$/, ''
      r.invitees = r.invitees.gsub /\s+/, ' '
      r.invitees = r.invitees.split(/\s*,\s*/).sort_by(&:upcase).join(",\n") + "\n"
    end
  end

  validates_presence_of :start_at

  before_update do |r|
    if !r.invitees.blank?
      r.invitees = r.invitees.gsub /^\s+/, ''
      r.invitees = r.invitees.gsub /\s+$/, ''
      r.invitees = r.invitees.gsub /\s+/, ' '
      r.invitees = r.invitees.split(/\s*,\s*/).sort_by(&:upcase).join(",\n") + "\n"
      r.invitees.split(/\s*,\s*/).each do |inv|
        if inv =~ /^(.*) <(.*@.*)>$/
          name, email = $1, $2
        elsif inv =~ /^(.*@.*)$/
            name, email = $1, $1
        else
          name, email = inv, inv
        end
        event_invitees.create :name => name, :email => email
      end
      r.invitees = nil
    end
  end

  def ingress
    description.try(:slice, %r{\A.*?(?:<br ?/><br ?/>|</p>|\Z)}im)
  end
  
  def body
    ingress = self.ingress
    if ingress && description.size > ingress.size
      description[ingress.size..-1]
    else
      nil
    end
  end

  def size
    event_invitees.select { |ei| ei.will_attend }.size
  end

end
