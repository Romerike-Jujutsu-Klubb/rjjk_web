# frozen_string_literal: true

require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern.
class User < ApplicationRecord
  include UserSystem

  attr_accessor :password, :password_confirmation

  has_one :member, dependent: :nullify
  has_many :embus, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :news_items, dependent: :destroy, inverse_of: :creator, foreign_key: :created_by
  has_many :news_item_likes, dependent: :destroy

  # http://www.postgresql.org/docs/9.3/static/textsearch-controls.html#TEXTSEARCH-RANKING
  SEARCH_FIELDS = %i[email first_name last_name login].freeze
  scope :search, ->(query) {
    where(SEARCH_FIELDS.map { |c| "to_tsvector(UPPER(#{c})) @@ to_tsquery(:query)" }.join(' OR '),
        query: UnicodeUtils.upcase(query).split(/\s+/).join(' | '))
        .order(:first_name, :last_name)
  }

  CHANGEABLE_FIELDS = %w[first_name last_name email].freeze
  attr_accessor :password_needs_confirmation

  before_validation do
    self.login = email if login.blank?
    self.email = email.downcase if email && email_changed?
  end
  after_save { @password_needs_confirmation = false }
  after_validation :crypt_password

  validates :login, presence: { on: :create }
  validates :login, length: { within: 3..64, on: :create, allow_blank: true }
  validates :login, uniqueness: { on: :create }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  validates :password, presence: { if: :validate_password? }
  validates :password, confirmation: { if: :validate_password? }
  validates :password, length: { within: 5..40, if: :validate_password? }

  validate do
    if role_changed? && role.present? && !current_user.admin?
      errors.add(:role, 'Bare administratorer kan gi administratorrettigheter.')
    end
  end

  def initialize(*args)
    super
    @password_needs_confirmation = false
  end

  def self.find_administrators
    where('role = ?', UserSystem::ADMIN_ROLE).all
  end

  def self.authenticate(login, pass)
    users = includes(:member).references(:members)
        .where('login = ? OR users.email = ? OR (members.email IS NOT NULL AND members.email = ?)',
            login, login, login)
        .where('verified = ? AND (deleted IS NULL OR deleted = ?)',
            true, false).to_a
    users
        .select { |u| u.salted_password == salted_password(u.salt, hashed(pass)) }
        .first
  end

  # Allow logins for deleted accounts, but only via this method
  # (and not the regular authenticate call)
  def self.authenticate_by_token(token)
    logger.info "Attempting authentication with token: #{token.inspect}"
    if (u = find_by(security_token: token))
      logger.info "Identified by token: #{u.inspect}"
    else
      logger.info 'Not authenticated'
      return nil
    end
    if u.token_expired?
      logger.info 'Token expired.'
      return nil
    end
    logger.info "Authenticated by token: #{u.inspect}.  Extending token lifetime."
    u.update! verified: true, token_expiry: Time.current + token_lifetime
    u
  end

  def self.salted_password(salt, hashed_password)
    hashed(salt + hashed_password)
  end

  def self.hashed(str)
    Digest::SHA1.hexdigest("Man må like å lide!--#{str}--")[0..39]
  end

  def self.token_lifetime(duration = :short)
    duration_key = duration == :login ? :autologin_token_life_hours : :security_token_life_hours
    UserSystem::CONFIG[duration_key].hours
  end

  def full_email
    current_email = member&.email || email
    if current_email =~ /<(.*)>/
      current_email
    else
      %("#{name}" <#{current_email}>)
    end
  end

  def emails
    result = [full_email]
    result += member.emails if member
    result.sort_by! { |e| -e.size }
    result.uniq { |e| e =~ /<(.*@.*)>/ ? Regexp.last_match(1) : e }
  end

  def name
    member.try(:name) || (
    if first_name.present? || last_name.present?
      [first_name, last_name].select(&:present?).join(' ')
    else
      login
    end)
  end

  def token_expired?
    security_token && token_expiry && (Time.current >= token_expiry)
  end

  def generate_security_token(duration = :short)
    if security_token.nil? || token_expiry.nil? || token_stale?(duration)
      new_security_token(duration)
    else
      security_token
    end
  end

  def token_stale?(duration)
    remaining_token_lifetime < (User.token_lifetime(duration) / 2)
  end

  def change_password(pass, confirm = nil)
    self.password = pass
    self.password_confirmation = confirm.nil? ? pass : confirm
    @password_needs_confirmation = true
  end

  def remaining_token_lifetime
    token_expiry.to_i - Time.current.to_i
  end

  def admin?
    role == UserSystem::ADMIN_ROLE || member.try(:admin?)
  end

  def technical_committy?
    member.try(:technical_committy?)
  end

  def instructor?
    member.try(:instructor?)
  end

  protected

  def validate_password?
    @password_needs_confirmation
  end

  def crypt_password
    return unless @password_needs_confirmation
    self['salt'] = self.class.hashed("salt-#{Time.current}")
    self['salted_password'] = self.class.salted_password(salt, self.class.hashed(@password))
  end

  def new_security_token(duration)
    self['security_token'] = self.class.hashed(salted_password + Time.current.to_i.to_s + rand.to_s)
    self['token_expiry'] = Time.zone.at(Time.current.to_i + User.token_lifetime(duration))
    save
    security_token
  end
end
