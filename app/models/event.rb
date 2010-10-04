class Event < ActiveRecord::Base
  default_scope :order => 'start_at DESC'

  def ingress
    description.slice(/^.*?<\/p>/)
  end
  
end
