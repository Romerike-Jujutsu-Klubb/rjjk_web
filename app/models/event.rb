class Event < ActiveRecord::Base
  default_scope :order => 'start_at DESC'
end
