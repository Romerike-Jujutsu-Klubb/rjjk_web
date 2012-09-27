class EventInvitee < ActiveRecord::Base
  attr_accessible :address, :comment, :email, :event_id, :name, :organization, :payed, :phone, :user_id, :will_attend, :will_work

  belongs_to :event
  belongs_to :user
  has_one :signup_confirmation, :class_name => 'EventInviteeMessage', :conditions => "message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'"
  has_one :signup_rejection, :class_name => 'EventInviteeMessage', :conditions => "message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'"

  validates_presence_of :name, :email
  validates_uniqueness_of :user_id, :scope => :event_id, :allow_nil => true
  validates_inclusion_of :will_work, :in => [nil, false], :if => proc{|r| r.will_attend == false}
end
