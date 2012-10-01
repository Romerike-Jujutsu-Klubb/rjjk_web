class EventMessage < ActiveRecord::Base
  module MessageType
    INVITATION = 'INVITATION'
  end

  attr_accessible :body, :event_id, :message_type, :ready_at, :subject

  belongs_to :event

  validates_presence_of :body, :event_id, :message_type, :subject
  validates_uniqueness_of :event_id, :scope => :message_type
end
