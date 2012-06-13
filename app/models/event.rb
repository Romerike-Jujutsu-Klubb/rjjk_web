class Event < ActiveRecord::Base
  default_scope :order => 'start_at'

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
