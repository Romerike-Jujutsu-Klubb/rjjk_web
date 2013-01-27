class EventInvitee < ActiveRecord::Base
  attr_accessible :address, :comment, :email, :event, :event_id, :name, :organization, :payed, :phone, :user_id, :will_attend, :will_work

  belongs_to :event
  belongs_to :user
  has_one :invitation, :class_name => 'EventInviteeMessage', :conditions => "message_type = '#{EventMessage::MessageType::INVITATION}'", :dependent => :destroy
  has_one :signup_confirmation, :class_name => 'EventInviteeMessage', :conditions => "message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'", :dependent => :destroy
  has_one :signup_rejection, :class_name => 'EventInviteeMessage', :conditions => "message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'", :dependent => :destroy
  has_many :event_invitee_messages, :conditions => "message_type <> '#{EventMessage::MessageType::INVITATION}'", :dependent => :destroy

  validates_presence_of :event, :event_id, :name, :email
  validates_uniqueness_of :user_id, :scope => :event_id, :allow_nil => true
  validates_inclusion_of :will_work, :in => [nil, false], :if => proc{|r| r.will_attend == false}

  before_create do
    if user
      self.name = user.name
      self.email = user.email
      self.organization = 'Romerike Jujutsu Klubb' if user.member
    end
  end

  def name
    user.try(:name) || super
  end

  def email
    user.try(:email) || super
  end

end
