# frozen_string_literal: true

require 'digest/sha1'

class User < ApplicationRecord
  include UserSystem
  include Rails.application.routes.url_helpers
  include Searching

  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  has_paper_trail
  acts_as_paranoid

  attr_accessor :password, :password_confirmation, :password_needs_confirmation

  geocoded_by :full_address
  after_validation :geocode, if: ->(u) do
    (u.address.present? || u.postal_code.present?) &&
        ((latitude.blank? || longitude.blank? || u.address_changed? || u.postal_code_changed?))
  end

  belongs_to :billing_user, class_name: 'User', optional: true
  belongs_to :contact_user, class_name: 'User', optional: true
  belongs_to :guardian_1, class_name: 'User', optional: true
  belongs_to :guardian_2, class_name: 'User', optional: true

  has_one :card_key, dependent: :nullify
  has_one :last_membership, -> { order(joined_on: :desc, left_on: :desc) }, inverse_of: :user,
            class_name: 'Member'
  has_one :member, -> { where(left_on: nil).order(joined_on: :desc) }, inverse_of: :user,
      dependent: :restrict_with_exception

  has_many :attendances, dependent: :destroy
  has_many :contactees, dependent: :nullify, class_name: 'User', foreign_key: :contact_user_id,
      inverse_of: :contact_user
  has_many :embus, dependent: :destroy
  has_many :event_invitees, dependent: :restrict_with_error
  has_many :group_memberships, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :memberships, dependent: :restrict_with_error,
      class_name: 'Member', # TODO(uwe): Remove line after rename Member => Membership
      inverse_of: :user
  has_many :news_item_likes, dependent: :destroy
  has_many :news_items, dependent: :destroy, inverse_of: :creator, foreign_key: :created_by
  has_many :payees, dependent: :nullify, class_name: 'User', foreign_key: :billing_user_id,
      inverse_of: :billing_user
  has_many :primary_wards, dependent: :nullify, class_name: 'User', foreign_key: :guardian_1_id,
      inverse_of: :guardian_1
  has_many :recent_attendances, -> { merge(Attendance.from_date(92.days.ago).to_date(31.days.from_now)) },
      class_name: :Attendance, inverse_of: :user
  has_many :secondary_wards, dependent: :nullify, class_name: 'User', foreign_key: :guardian_2_id,
      inverse_of: :guardian_2
  has_many :signatures, dependent: :destroy
  has_many :signups, dependent: :destroy
  has_many :user_messages, dependent: :destroy

  has_many :groups, through: :group_memberships

  scope :absent_since, ->(from_date = nil, to_date = nil) do
    where.not(id: attending_since(from_date, to_date))
  end
  scope :attending_since, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.current
    to_date ||= Date.current
    merge(Attendance.from_date(from_date).to_date(to_date))
  end

  accepts_nested_attributes_for :guardian_1

  search_scope %i[address email first_name last_name login phone postal_code security_token],
      order: %i[first_name last_name]

  CHANGEABLE_FIELDS = %w[first_name last_name email].freeze

  NILLABLE_FIELDS = %i[address email first_name kana last_name login phone postal_code role].freeze
  before_validation do
    NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? }
    self.email = email.strip.downcase if email.present?
    self.verified = false if email_changed?
    self.phone = phone.delete(' ') if phone
    self.phone = Regexp.last_match(1) if phone =~ /^\+47\s*(.*)$/
    self.locale ||= 'nb'
    first_name&.strip!
    last_name&.strip!
  end
  after_save { @password_needs_confirmation = false }
  after_validation :crypt_password

  validates :birthdate, presence: true, if: -> { member && member.left_on.nil? }
  validates :male, inclusion: { in: [true, false] }, if: -> { signups.any? || member&.left_on&.nil? }
  validates :email,
      format: { with: EMAIL_REGEXP, allow_nil: true },
      uniqueness: { case_sensitive: false, scope: :deleted_at, unless: :deleted_at, allow_nil: true }
  # validates :guardian_1_id, presence: { if: -> {age && age < 18} }
  validates :login, length: { within: 3..64 }, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :password, presence: { if: :validate_password? },
      confirmation: { if: :validate_password? },
      length: { within: 5..40, if: :validate_password? }
  validates :phone, uniqueness: { allow_nil: true }, length: { minimum: 4, allow_nil: true }
  # presence: { unless: ->{email || member} } # TODO(uwe): Activate this?  Ensure contact method!
  validates :postal_code, length: { is: 4, allow_blank: true }

  validate do
    if will_save_change_to_role? && role.present? && !current_user&.admin?
      errors.add(:role, 'Bare administratorer kan gi administratorrettigheter.')
    end
    errors.add(:base, 'trenger kontaktinfo.') unless deleted? || contact_info?
    # if !left_on && !billing_user&.email && user.emails.empty?
    #   errors.add :base, 'The member is missing a contact email'
    # end
    if billing_user && billing_user&.email.blank? && billing_user&.phone.blank?
      errors.add :billing_user_id, 'trenger e-post eller telefon'
      billing_user.errors.add :email, I18n.t('activerecord.errors.messages.blank')
    end
  end
  # validates_associated :member, on: :update # TODO(uwe): Activate this?

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
        .where('verified = ? AND (deleted_at IS NULL)', true).to_a
    users.find { |u| u.salted_password == salted_password(u.salt, hashed(pass)) }
  end

  # Allow logins for deleted accounts, but only via this method
  # (and not the regular authenticate call)
  def self.authenticate_by_token(token)
    logger.info "Attempting authentication with token: #{token.inspect}"
    if (u = find_by(security_token: token))
      if u.token_expired?
        logger.info 'Token expired.'
        return nil
      end
      logger.info "Authenticated by user token: #{u.inspect}.  Extending token lifetime."
      u.token_expiry = token_lifetime(:login).from_now
    elsif (u = (um = UserMessage.includes(:user).for_login.find_by(key: CGI.unescape(token)))&.user)
      logger.info "Identified by user message token: #{u.inspect}"
      um.update!(read_at: Time.current) unless um.read_at
    else
      logger.info 'Not authenticated'
      return nil
    end
    u.update! verified: true
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
    if /<(.*)>/.match?(current_email)
      current_email
    else
      %("#{name}" <#{current_email}>)
    end
  end

  def guardians
    [guardian_1, guardian_2].compact
  end

  def emails
    contact_users.map(&:email).reject(&:nil?).uniq.sort
  end

  def emails_was
    contact_users.map(&:email_was).reject(&:nil?).uniq.sort
  end

  def phones
    contact_users.map(&:phone).reject(&:nil?).uniq
  end

  def label(last_name_first: false)
    name(last_name_first: last_name_first) || email || phone
  end

  def name(last_name_first: false)
    if last_name_first
      [last_name, first_name].select(&:present?).join(', ').presence
    else
      [first_name, last_name].select(&:present?).join(' ').presence
    end
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

  def to_vcard
    photo_src =
        if member&.image
          binary = Base64.encode64(member.image.content_data_io.string).chomp("\n").gsub("\n", "\n ")
          "TYPE=#{member.image.format.upcase};ENCODING=b:#{binary}"
        else
          "VALUE=URI;TYPE=JPEG:#{photo_user_url(self, format: :jpeg)}"
        end
    <<~VCARD
      BEGIN:VCARD
      VERSION:3.0
      N:#{last_name};#{first_name};;;
      FN:#{name}
      PHOTO;#{photo_src}
      TEL;TYPE=mobile:#{phone}
      ADR;TYPE=HOME,PREF:;;#{address};#{postal_code};Norway
      LABEL;TYPE=HOME:#{address}\n#{postal_code}\nNorway
      EMAIL:#{email}
      REV:#{updated_at.iso8601}
      END:VCARD
    VCARD
  end

  def token_expired?
    security_token && token_expiry && (Time.current >= token_expiry)
  end

  def generate_security_token(duration = :short)
    if security_token.nil? || token_expiry.nil? || token_stale?(duration)
      self.salt ||= self.class.hashed("salt-#{Time.current}")
      self.salted_password ||=
          self.class.salted_password(salt, self.class.hashed(SecureRandom.urlsafe_base64(12)))
      new_security_token(duration)
    else
      security_token
    end
  end

  def reset_security_token
    update! security_token: nil, token_expiry: nil
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
    role == UserSystem::ADMIN_ROLE || member&.admin?
  end

  def member?(date_time = DateTime.current)
    member.present? && member.joined_on <= date_time && !member.left?(date_time)
  end

  def technical_committy?
    member&.technical_committy?
  end

  def instructor?
    member&.instructor?
  end

  # describe how to retrieve the address from your model, if you use directly a
  # db column, you can dry your code, see wiki
  def full_address
    [address, postal_code, 'Norway'].select(&:present?).join(', ')
  end

  def map_url
    return "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}" if latitude
    return "https://www.google.com/maps/place/#{full_address}" if full_address
  end

  def contact_user_was
    @contact_user_was ||= contact_user_id_was && User.find(contact_user_id_was)
  end

  def contact_info?
    emails.any? || phones.any?
  end

  def contact_info
    contact_phone || contact_email
  end

  def contact_phone
    phones.first
  end

  def contact_email
    contact_users.find { |u| u.email.present? }&.email
  end

  def contact_email_was
    contact_user_was&.email_was || email_was || emails_was&.first || billing_user_was&.email_was
  end

  def contact_email=(value)
    logger.info "user(#{id}).contact_email = #{value.inspect}"
    previous_contact_email = contact_email
    logger.info "previous_contact_email: #{previous_contact_email.inspect}"
    return if value == previous_contact_email

    new_contact_user = User.find_by(email: value) if value.present?
    logger.info "new_contact_user: #{new_contact_user.inspect}"
    if new_contact_user&.== self
      logger.info 'clear contact user id'
      self.contact_user_id = nil
    elsif new_contact_user
      logger.info 'set new contact user'
      self.contact_user = new_contact_user
    else
      logger.info 'Update user email'
      self.email = value
    end
  end

  def contact_email_changed?
    contact_email_was != contact_email
  end

  def guardian_1_or_billing_name
    guardian_1&.name || billing_user&.name
  end

  def guardian_1_or_billing_name_was
    guardian_1&.name_was || billing_user&.name_was
  end

  def guardian_1_or_billing_name=(value)
    u = guardian_1 || billing_user
    u = self.guardian_1 = User.new if u.nil? && value.present?
    u.name = value if u
  end

  def multiple_depending_members?
    [payees, primary_wards, secondary_wards, contactees]
        .inject([]) { |list, a| list.size > 1 ? (break list) : (list + a).uniq }.size > 1
  end

  def depending_users
    [payees, primary_wards, secondary_wards, contactees].inject(&:+).uniq
  end

  def contact_users
    %i[contact_user itself guardian_1 guardian_2 billing_user].lazy.map { |m| send(m) }.reject(&:nil?)
  end

  def sex_label
    return if male.nil?

    male ? 'Mann' : 'Kvinne'
  end

  def attending?(date = Date.current, group = nil)
    !absent?(date, group)
  end

  def absent?(date = Date.current, group = nil, days: 92)
    return false if member && date <= member.joined_on + 2.months

    start_date = date - days
    end_date = date + 31
    if date >= Date.current && recent_attendances.loaded?
      set = recent_attendances
          .select { |a| Attendance::PRESENT_STATES.include?(a.status) && a.date > start_date }
      set = set.select { |a| a.group_schedule.group_id == group.id } if group
      set.empty?
    elsif attendances.loaded?
      set = attendances.select { |a| Attendance::PRESENT_STATES.include? a.status }
      set = set.select { |a| a.group_schedule.group_id == group.id } if group
      set = set.select { |a| a.date > start_date && a.date <= end_date }
      set.empty?
    else
      query = attendances.where('attendances.status IN (?)', Attendance::PRESENCE_STATES)
      query = query.by_group_id(group.id) if group
      query = query.from_date(start_date).to_date(end_date)
      query.empty?
    end
  end

  def attendances_since_graduation(before_date = Date.current,
      practice_groups = Group.includes(:martial_art).to_a, includes: nil, include_absences: false)
    queries = Array(practice_groups).map do |g|
      ats = attendances
      ats = ats.where(status: Attendance::PRESENT_STATES) unless include_absences
      ats = ats.by_group_id(g.id)
      if (c = last_membership&.current_graduate(g.martial_art, before_date))
        ats = ats.after(c.graduation.held_on)
      end
      ats = ats.to_date(before_date)
      ats = ats.includes(includes) if includes
      ats
    end
    query = case queries.size
            when 0
              Attendance.none
            when 1
              queries.first
            else
              queries.inject(:or)
            end
    query.order('practices.year, practices.week').reverse_order
  end

  def current_rank
    last_membership&.current_rank || Rank::UNRANKED
  end

  protected

  def validate_password?
    @password_needs_confirmation
  end

  def crypt_password
    return unless @password_needs_confirmation

    self.salt = self.class.hashed("salt-#{Time.current}")
    self.salted_password = self.class.salted_password(salt, self.class.hashed(@password))
  end

  def new_security_token(duration)
    self.security_token = self.class.hashed(salted_password + Time.current.to_i.to_s + rand.to_s)
    self.token_expiry = User.token_lifetime(duration).from_now
    save!
    security_token
  end
end
