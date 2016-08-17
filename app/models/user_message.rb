# frozen_string_literal: true
class UserMessage < ActiveRecord::Base
  serialize :from
  serialize :email_url

  belongs_to :user

  scope :for_user, -> (user_id) { where user_id: user_id }
  scope :tagged_as, -> (tag) { where tag: tag }
  scope :pending, -> { where(sent_at: nil, read_at: nil).order(:id) }

  before_validation do
    self.key ||= BCrypt::Password.create(Time.now.to_i.to_s + rand.to_s).checksum
  end
  validates_length_of :subject, maximum: 160, allow_blank: false
  validates_length_of :key, maximum: 64, allow_blank: false
  validates :tag, length: { maximum: 64 }

  def to
    user.emails
  end

  def body
    html_body || plain_body
  end
end
