class Event < ActiveRecord::Base
  default_scope :order => 'start_at'

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
