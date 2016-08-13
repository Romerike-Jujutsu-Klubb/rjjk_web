require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern.
class User < ActiveRecord::Base
  include UserSystem

  attr_accessor :password, :password_confirmation

  has_one :member
  has_many :embus, :dependent => :destroy
  has_many :images, :dependent => :destroy

  # http://www.postgresql.org/docs/9.3/static/textsearch-controls.html#TEXTSEARCH-RANKING
  SEARCH_FIELDS = [:email, :first_name, :last_name, :login]
  scope :search, ->(query) {
    where(SEARCH_FIELDS.map { |c| "to_tsvector(UPPER(#{c})) @@ to_tsquery(?)" }
        .join(' OR '), *([UnicodeUtils.upcase(query).split(/\s+/).join(' | ')] * SEARCH_FIELDS.size))
        .order(:first_name, :last_name)
  }

  CHANGEABLE_FIELDS = %w(first_name last_name email)
  attr_accessor :password_needs_confirmation

  before_validation { self.login = email if login.blank? }
  after_save { @password_needs_confirmation = false }
  after_validation :crypt_password

  validates_presence_of :login, :on => :create
  validates_length_of :login, :within => 3..64, :on => :create, :allow_blank => true
  validates_uniqueness_of :login, :on => :create
  validates_uniqueness_of :email, :on => :create

  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  validates_length_of :password, :within => 5..40, :if => :validate_password?

  def validate
    if role_changed? && (user.nil? || user.role.nil?)
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
        .where('(login = ? OR users.email = ? OR (members.email IS NOT NULL AND members.email = ?)) AND verified = ? AND (deleted IS NULL OR deleted = ?)',
            login, login, login, true, false).to_a
    users
        .select { |u| u.salted_password == salted_password(u.salt, hashed(pass)) }
        .first
  end

  # Allow logins for deleted accounts, but only via this method
  # (and not the regular authenticate call)
  def self.authenticate_by_token(token)
    logger.info "Attempting authentication with token: #{token.inspect}"
    if (u = where('security_token = ?', token).first)
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
    u.update_attributes :verified => true, :token_expiry => Time.now + token_lifetime
    u
  end

  def self.salted_password(salt, hashed_password)
    hashed(salt + hashed_password)
  end

  def self.hashed(str)
    Digest::SHA1.hexdigest("Man må like å lide!--#{str}--")[0..39]
  end

  def self.token_lifetime(duration = :short)
    UserSystem::CONFIG[duration == :login ? :autologin_token_life_hours : :security_token_life_hours].hours
  end

  def email
    member.try(:email) || super
  end

  def emails
    result = [%("#{name}" <#{attributes['email']}>)]
    result += member.emails if member
    result.sort_by! { |e| -e.size }
    result.uniq { |e| e =~ /<(.*@.*)>/ ? $1 : e }
  end

  def name
    member.try(:name) || (first_name.present? || last_name.present? ? [first_name, last_name].select(&:present?).join(' ') : login)
  end

  def token_expired?
    security_token && token_expiry && (Time.now >= token_expiry)
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
    token_expiry.to_i - Time.now.to_i
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
    if @password_needs_confirmation
      write_attribute('salt', self.class.hashed("salt-#{Time.now}"))
      write_attribute('salted_password', self.class.salted_password(salt, self.class.hashed(@password)))
    end
  end

  def new_security_token(duration)
    write_attribute('security_token', self.class.hashed(salted_password + Time.now.to_i.to_s + rand.to_s))
    write_attribute('token_expiry', Time.at(Time.now.to_i + User.token_lifetime(duration)))
    save
    security_token
  end
end
