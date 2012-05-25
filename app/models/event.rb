class Event < ActiveRecord::Base
  default_scope :order => 'start_at'

  validates_presence_of :start_at

  def ingress
    description.try(:slice, /\A.*?<\/p>/)
  end
  
end
