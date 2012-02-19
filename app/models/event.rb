class Event < ActiveRecord::Base
  default_scope :order => 'start_at DESC'

  validates_presence_of :start_at

  def ingress
    description.try(:slice, /^.*?<\/p>/)
  end
  
end
