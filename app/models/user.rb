# frozen_string_literal: true

require 'digest/sha1'

class User < ApplicationRecord
  include UserSystem

  attr_accessor :password, :password_confirmation

  # geocoded_by :full_address
  # after_validation :geocode, if: ->(u) {
  #   (u.address.present? || u.postal_code.present?) &&
  #       ((latitude.blank? || longitude.blank? || u.address_changed? || u.postal_code_changed?))
  # }

  has_one :member, dependent: :restrict_with_exception

  has_many :embus, dependent: :destroy
  has_many :guardianships, dependent: :destroy, inverse_of: :ward_user, foreign_key: :ward_user_id
  has_many :images, dependent: :destroy
  has_many :news_item_likes, dependent: :destroy
  has_many :news_items, dependent: :destroy, inverse_of: :creator, foreign_key: :created_by
  has_many :payees, dependent: :nullify, foreign_key: :billing_user_id, inverse_of: :billing_user
  has_many :user_messages, dependent: :destroy
  has_many :wardships, class_name: :Guardianship, dependent: :destroy, inverse_of: :guardian_user,
      foreign_key: :guardian_user_id

  # has_one :guardian_1, through: :guardianship_1, source: :guardian_user
  # has_one :guardian_2, through: :guardianship_2, source: :guardian_user

  has_many :wards, through: :wardships # , source: :ward_user
  has_many :guardians, through: :guardianships, source: :guardian_user

  # http://www.postgresql.org/docs/9.3/static/textsearch-controls.html#TEXTSEARCH-RANKING
  SEARCH_FIELDS = %i[address email first_name last_name login postal_code].freeze
  scope :search, ->(query) {
    where(SEARCH_FIELDS.map { |c| "to_tsvector(UPPER(#{c})) @@ to_tsquery(:query)" }.join(' OR '),
        query: UnicodeUtils.upcase(query).split(/\s+/).join(' | '))
        .order(:first_name, :last_name)
  }

  CHANGEABLE_FIELDS = %w[first_name last_name email].freeze
  attr_accessor :password_needs_confirmation

  NILLABLE_FIELDS = %i[first_name login].freeze
  before_validation do
    NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? }
    self.email = email.blank? ? nil : email.strip.downcase
    self.phone = Regexp.last_match(1) if phone =~ /^\+47\s*(.*)$/
  end
  after_save { @password_needs_confirmation = false }
  after_validation :crypt_password

  validates :birthdate, presence: true, if: ->{member && member.left_on.nil?}
  validates :male, inclusion: { in: [true, false] }, if: ->{member && member.left_on.nil?}
  validates :email, uniqueness: { case_sensitive: false, scope: :deleted, unless: :deleted },
      format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_nil: true
  validates :login, length: { within: 3..64 }, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :password, presence: { if: :validate_password? },
      confirmation: { if: :validate_password? },
      length: { within: 5..40, if: :validate_password? }
  validates :phone, uniqueness: true, allow_nil: true, length: { minimum: 4, allow_nil: true }
  validates :postal_code, length: { is: 4, allow_blank: true }

  validate do
    if will_save_change_to_role? && role.present? && !current_user&.admin?
      errors.add(:role, 'Bare administratorer kan gi administratorrettigheter.')
    end
  end

  # validates_associated :member, on: :update

  def initialize(*args)
    super
    @password_needs_confirmation = false
  end

  def self.find_administrators
    where('role = ?', UserSystem::ADMIN_ROLE).all
  end

  def self.authenticate(email, pass)
    users = includes(:member)
        .where('login = :email OR email = :email', email: email)
        .where('verified = ? AND (deleted IS NULL OR deleted = ?)', true, false).to_a
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

  def age(date = Date.current)
    return nil unless birthdate
    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
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
    result = ([email] + guardians.map(&:email)).compact
    result.sort_by! { |e| -e.size }
    result.uniq { |e| e =~ /<(.*@.*)>/ ? Regexp.last_match(1) : e }
  end

  def phones
    ([phone] + guardians.map(&:phone)).select(&:present?).uniq.sort
  end

  def name
    [first_name, last_name].select(&:present?).join(' ').presence
  end

  def name_was
    [first_name_was, last_name_was].select(&:present?).join(' ')
  end

  def name=(new_name)
    names = new_name.to_s.split(/\s+/)
    self[:first_name] = names[0..-2].join(' ')
    self[:last_name] = names[-1]
  end

  def to_s
    name || email
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

  def guardian_1
    guardianships.find { |g| g.index == 1 }&.guardian_user
  end

  def guardian_2
    guardianships.find { |g| g.index == 2 }&.guardian_user
  end

  # describe how to retrieve the address from your model, if you use directly a
  # db column, you can dry your code, see wiki
  def full_address
    [address, postal_code, 'Norway'].select(&:present?).join(', ')
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
