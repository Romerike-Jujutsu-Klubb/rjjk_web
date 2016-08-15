class EventInvitee < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  has_one :invitation, -> { where("message_type = '#{EventMessage::MessageType::INVITATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_confirmation,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_one :signup_rejection,
      -> { where("message_type = '#{EventInviteeMessage::MessageType::SIGNUP_REJECTION}'") },
      class_name: 'EventInviteeMessage', dependent: :destroy
  has_many :event_invitee_messages,
      -> { where("message_type IS NULL OR message_type <> '#{EventMessage::MessageType::INVITATION}'") },
      dependent: :destroy

  validates_presence_of :event, :event_id, :name, :email
  validates_uniqueness_of :user_id, scope: :event_id, allow_nil: true
  validates_inclusion_of :will_work, in: [nil, false], if: proc { |r| r.will_attend == false }

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
