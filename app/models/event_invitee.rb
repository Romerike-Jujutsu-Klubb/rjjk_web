class EventInvitee < ActiveRecord::Base
  attr_accessible :address, :email, :event_id, :name, :organization, :payed, :will_attend
end
