require 'digest/sha1'
require 'clock'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  include UserSystem

  has_one :member

  CHANGEABLE_FIELDS = %w(first_name last_name email)
  attr_accessor :password_needs_confirmation

  before_validation{self.login = email if self.login.blank?}
  after_save{@password_needs_confirmation = false}
  after_validation :crypt_password

  validates_presence_of :login, :on => :create
  validates_length_of :login, :within => 3..40, :on => :create, :allow_blank => true
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

  def initialize(attributes = nil)
    super
    @password_needs_confirmation = false
  end

  def self.find_administrators
    find(:all, :conditions => ['role = ?', UserSystem::ADMIN_ROLE])
  end

  def self.authenticate(login, pass)
    u = find(:first, :conditions => ["(login = ? OR email = ?) AND verified = ? AND deleted = ?", login, login, true, false])
    return nil if u.nil?
    find(:first, :conditions => ["(login = ? OR email = ?) AND salted_password = ? AND verified = ?", login, login, salted_password(u.salt, hashed(pass)), true])
  end

  def self.authenticate_by_token(id, token)
    # Allow logins for deleted accounts, but only via this method (and
    # not the regular authenticate call)
    logger.info "Attempting authorization of #{id} with #{token}"
    u = find( :first, :conditions => ["id = ? AND security_token = ?", id, token])
    if u
      logger.info "Authenticated by token: #{u.inspect}"
    else
      logger.info "Not authenticated" if u.nil?
    end
    return nil if (u.nil? or u.token_expired?)
    u.update_attributes :verified => true, :token_expiry => Clock.now
    return u
  end

  def token_expired?
    self.security_token and self.token_expiry and (Clock.now >= self.token_expiry)
  end

  def generate_security_token(duration = :short)
    if self.security_token.nil? or self.token_expiry.nil? or token_stale?(duration)
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

  def self.token_lifetime(duration = :short)
    UserSystem::CONFIG[duration == :login ? :autologin_token_life_hours : :security_token_life_hours].hours
  end

  def remaining_token_lifetime
    self.token_expiry.to_i - Clock.now.to_i
  end

  def admin?
    role == UserSystem::ADMIN_ROLE
  end

  def name
    "#{first_name} #{last_name}"
  end

  protected

  attr_accessor :password, :password_confirmation

  def validate_password?
    @password_needs_confirmation
  end

  def self.hashed(str)
    return Digest::SHA1.hexdigest("change-me--#{str}--")[0..39]
  end

  def crypt_password
    if @password_needs_confirmation
      write_attribute("salt", self.class.hashed("salt-#{Clock.now}"))
      write_attribute("salted_password", self.class.salted_password(salt, self.class.hashed(@password)))
    end
  end

  def new_security_token(duration)
    write_attribute('security_token', self.class.hashed(self.salted_password + Clock.now.to_i.to_s + rand.to_s))
    write_attribute('token_expiry', Time.at(Clock.now.to_i + User.token_lifetime(duration)))
    update
    self.security_token
  end

  def self.salted_password(salt, hashed_password)
    hashed(salt + hashed_password)
  end

end

