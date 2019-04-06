# frozen_string_literal: true

class UserMessage < ApplicationRecord
  serialize :from
  serialize :email_url

  belongs_to :user

  scope :for_user, ->(user_id) { where user_id: user_id }
  scope :for_login, -> { where 'created_at > ?', User.token_lifetime(:login).ago }
  scope :tagged_as, ->(tag) { where tag: tag }
  scope :pending, -> { where(sent_at: nil, read_at: nil).order(:id) }
  scope :search, ->(query) { where(key: query).order(:key) }

  before_validation do
    self.key ||= BCrypt::Password.create(Time.current.to_i.to_s + rand.to_s).checksum
  end
  validates :subject, length: { maximum: 255, allow_blank: false }
  validates :key, length: { maximum: 64, allow_blank: false }
  validates :tag, length: { maximum: 64 }
  validates :title, length: { maximum: 255 }

  def to
    user.emails
  end

  def body
    html_body || plain_body
  end
end
