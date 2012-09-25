class Event < ActiveRecord::Base
  default_scope :order => 'start_at'

  has_many :event_invitees, :order => :name
  has_and_belongs_to_many :groups

  before_validation do |r|
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
    description.try(:slice, /\A.*?<\/p>/)
  end
  
  def body
    ingress = self.ingress
    if ingress && description.size > ingress.size
      description[ingress.size..-1]
    else
      nil
    end
  end

end
