class EventInvitee < ActiveRecord::Base
  attr_accessible :address, :email, :event_id, :name, :organization, :payed, :phone, :user_id, :will_attend

  belongs_to :event

  validates_presence_of :name, :email, :user, :user_id
  validates_uniqueness_of :user_id, :scope => :event_id
end
