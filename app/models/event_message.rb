class EventMessage < ActiveRecord::Base
  module MessageType
    INFORMATION = 'INFORMATION'
    INVITATION = 'INVITATION'
    REMINDER = 'REMINDER'
  end

  belongs_to :event
  has_many :event_invitee_messages

  validates_presence_of :body, :event_id, :message_type, :subject
  validates_uniqueness_of :event_id, :scope => :message_type,
                          :if => proc{|mt| mt.message_type == MessageType::INVITATION}
end
