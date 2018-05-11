# frozen_string_literal: true

# TODO(uwe): Rename to Membership
class Member < ApplicationRecord
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'
  SEARCH_FIELDS =
      %i[address billing_address comment nkf_members.medlemsnummer phone_home phone_work].freeze

  # geocoded_by :full_address
  # after_validation :geocode, if: ->(m) {
  #   (m.address.present? || m.postal_code.present?) &&
  #       ((latitude.blank? || longitude.blank? || m.address_changed? || m.postal_code_changed?))
  # }

  belongs_to :billing_user, required: false, class_name: :User
  belongs_to :contact_user, class_name: :User, optional: true
  belongs_to :user, inverse_of: :member

  has_one :last_member_image, -> { order :created_at }, class_name: :MemberImage
  has_one :image, through: :last_member_image
  has_one :next_graduate, -> do
    includes(:graduation).where('graduations.held_on >= ?', Date.current)
        .order('graduations.held_on')
  end, class_name: :Graduate
  has_one :nkf_member, dependent: :nullify

  has_many :appointments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :censors, dependent: :destroy
  has_many :correspondences, dependent: :destroy
  has_many :elections, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :group_instructors, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :last_6_months_attendances, -> do
    includes(practice: :group_schedule).references(:group_schedules)
        .merge(Attendance.after(count.months.ago.to_date).before(Time.zone.today))
  end,
      class_name: :Attendance

  has_many :member_images, dependent: :destroy
  has_many :passed_graduates, -> { where graduates: { passed: true } },
      class_name: 'Graduate'
  has_many :recent_attendances,
      -> { merge(Attendance.after(92.days.ago).before(31.days.from_now)) },
      class_name: :Attendance

  has_many :signatures, dependent: :destroy
  has_many :survey_requests, dependent: :destroy

  has_many :groups, through: :group_memberships
  has_many :ranks, through: :passed_graduates

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :billing_user

  scope :active, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.current
    to_date ||= from_date
    where('joined_on <= ? AND left_on IS NULL OR left_on >= ?', to_date, from_date)
  end
  scope :search, ->(query) do
    includes(:nkf_member).references(:nkf_members)
        .where(SEARCH_FIELDS.map { |c| "UPPER(#{c}::text) ~ :query" }.join(' OR '),
            query: UnicodeUtils.upcase(query).split(/\s+/).join('|'))
    # .order(:first_name, :last_name)
  end
  scope :with_user, -> { includes(:user) }

  NILLABLE_FIELDS = %i[phone_home phone_work].freeze
  before_validation do
    NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? }
  end

  validates :address, presence: true, allow_blank: true # Allow members to omit their home address
  validates :billing_postal_code, length: { is: 4,
                                            if: proc { |m| m.billing_postal_code.present? } }
  validates :birthdate, presence: true, unless: :left_on
  validates :instructor, inclusion: { in: [true, false] }
  validates :joined_on, presence: true
  validates :male, inclusion: { in: [true, false] }
  validates :nkf_fee, inclusion: { in: [true, false] }
  validates :payment_problem, inclusion: { in: [true, false] }
  validates :postal_code, length: { is: 4, allow_blank: true }
  validates :user, presence: true

  validate do
    if !left_on && !billing_user&.email && user.emails.empty?
      errors.add :base, 'The member is missing a contact email'
    end
    if user.first_name.blank?
      errors.add :base, 'The member is missing a first name'
      user.errors.add :first_name, I18n.t('activerecord.errors.messages.blank')
    end
    if user.last_name.blank?
      errors.add :base, 'The member is missing a last name'
      user.errors.add :last_name, I18n.t('activerecord.errors.messages.blank')
    end
    if billing_user && billing_user&.email.blank?
      errors.add :billing_user_id, 'requires email'
      billing_user.errors.add :email, I18n.t('activerecord.errors.messages.blank')
    end
  end

  def self.paginate_active(page)
    active.order(:id).paginate(page: page, per_page: MEMBERS_PER_PAGE)
  end

  def self.instructors(date = Date.current)
    active(date).where(<<~SQL).order(:id).to_a
      instructor = true OR id IN (SELECT member_id FROM group_instructors GROUP BY member_id)
        SQL
  end

  delegate :email, :first_name, :last_name, :name, to: :user, allow_nil: true

  # describe how to retrieve the address from your model, if you use directly a
  # db column, you can dry your code, see wiki
  def full_address
    [address, postal_code, 'Norway'].select(&:present?).join(', ')
  end

  def gmaps4rails_infowindow
    html = +''
    if image?
      html << "<img src='/members/thumbnail/#{id}.#{image.format}' width='128' " \
          "style='float: left; margin-right: 1em'>"
    end
    html << name
    html
  end

  def current_graduate(martial_art, date = Date.current)
    graduates.includes(:graduation, :rank).sort_by { |g| -g.rank.position }
        .find do |g|
      g.passed? && g.graduation.held_on < date &&
          (martial_art.nil? || g.rank.martial_art_id == martial_art.id)
    end
  end

  def attendances_since_graduation(before_date = Date.current, group = nil, includes: nil,
      include_absences: false)
    groups = group ? [group] : Group.includes(:martial_art).to_a
    queries = groups.map do |g|
      ats = attendances
      ats = ats.where(status: Attendance::PRESENT_STATES) unless include_absences
      ats = ats.by_group_id(g.id)
      if (c = current_graduate(g.martial_art, before_date))
        ats = ats.after_date(c.graduation.held_on)
      end
      ats = ats.until_date(before_date)
      ats = ats.includes(includes) if includes
      ats
    end
    case queries.size
    when 0
      Attendance.none
    when 1
      queries.first.order(:year, :week).reverse_order
    else
      # query = queries.inject(:or) # Rails 5
      queries.map(&:to_a).flatten.sort_by(&:date).reverse
    end
  end

  def current_rank(martial_art = nil, date = Date.current)
    current_graduate(martial_art, date)&.rank
  end

  def current_rank_date(martial_art = nil, date = Date.current)
    graduate = current_graduate(martial_art, date)
    graduate&.graduation&.held_on || joined_on
  end

  def current_rank_age(martial_art, to_date)
    date = current_rank_date(martial_art, to_date)
    days = (to_date - date).to_i
    years = (to_date - date).to_i / 365
    months = (days - (years * 365)) / 30
    [years.positive? ? "#{years} år" : nil, years.zero? || months.positive? ? "#{months} mnd" : nil]
        .compact.join(' ')
  end

  def next_rank(graduation =
      Graduation.new(held_on: Date.current, group: groups.sort_by(&:from_age).last))
    age = self.age(graduation.held_on)
    ma = graduation.group.try(:martial_art) ||
        MartialArt.includes(:ranks).find_by(name: 'Kei Wa Ryu')
    current_rank = current_rank(ma, graduation.held_on)
    ranks = ma.ranks.to_a
    if current_rank
      next_rank = ranks.find do |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            (r.group.from_age..r.group.to_age).cover?(age) &&
            (age.nil? || age >= r.minimum_age) &&
            attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
      end
      next_rank ||= ranks.find do |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            (age.nil? || age >= r.group.from_age) &&
            (age.nil? || age >= r.minimum_age) &&
            attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
      end
      next_rank ||= ranks.find do |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            (r.group.from_age..r.group.to_age).cover?(age) &&
            (age.nil? || age >= r.minimum_age)
      end
      next_rank ||= ranks.find { |r| r.position > current_rank.position }
    end
    next_rank ||= ranks.find do |r|
      !future_ranks(graduation.held_on, ma).include?(r) &&
          (r.group.from_age..r.group.to_age).cover?(age) &&
          (age.nil? || age >= r.minimum_age) &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    end
    next_rank ||= ranks.find do |r|
      !future_ranks(graduation.held_on, ma).include?(r) &&
          (age.nil? || age >= r.minimum_age) &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    end
    next_rank ||= ranks.find do |r|
      age.nil? || (age >= r.minimum_age && (r.group.from_age..r.group.to_age).cover?(age))
    end
    next_rank ||= ranks.first
    next_rank
  end

  def future_graduates(after, martial_art_id)
    graduates.select do |g|
      g.passed? && g.graduation.group.martial_art_id == martial_art_id &&
          g.graduation.held_on > after
    end
  end

  def future_ranks(after, martial_art_id)
    future_graduates(after, martial_art_id).map(&:rank)
  end

  def fee
    if instructor?
      0
    elsif senior?
      300 + nkf_fee_amount
    else
      260 + nkf_fee_amount
    end
  end

  def active?(date = Date.current)
    !passive?(date)
  end

  def passive?(date = Date.current, group = nil)
    return true if passive_on
    return false if joined_on >= date - 2.months
    start_date = date - 92
    end_date = date + 31
    if date == Date.current && recent_attendances.loaded?
      set = recent_attendances.select { |a| Attendance::PRESENT_STATES.include? a.status }
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
      query = query.after_date(start_date)
      query = query.until_date(end_date)
      query.empty?
    end
  end

  def senior?
    birthdate && (age >= JUNIOR_AGE_LIMIT)
  end

  def nkf_fee_amount
    if senior?
      (nkf_fee? ? (279.0 / 12).ceil : 0)
    else
      (nkf_fee? ? (155.0 / 12).ceil : 0)
    end
  end

  def age(date = Date.current)
    return nil unless birthdate
    age = date.year - birthdate.year
    age -= 1 if date < birthdate + age.years
    age
  end

  def age_group
    return nil unless age
    if age >= JUNIOR_AGE_LIMIT
      'Senior'
    else
      'Junior'
    end
  end

  def gender
    if male
      'Mann'
    else
      'Kvinne'
    end
  end

  # FIXME(uwe): Design better!
  def membership
    self
  end

  def member
    user
  end

  def parent_1
    user.guardian_1
  end

  def parent_2
    user.guardian_2
  end

  def billing
    billing_user
  end
  # EMXIF

  def guardians
    user.guardians.order('guardianships.index')
  end

  def image_file=(file)
    return if file.blank?
    transaction do
      image = Image.create! user_id: user.id, name: file.original_filename,
          content_type: file.content_type, content_data: file.read
      member_images << MemberImage.new(image_id: image.id)
    end
  end

  def image?
    image.present?
  end

  def thumbnail(x = 120, y = 160)
    return unless image?
    magick_image = Magick::Image.from_blob(image.content_data).first
    magick_image.crop_resized(x, y).to_blob
  end

  def contact_email
    contact_user&.email || user&.email || user&.emails&.first || billing_user&.email || 'post@jujutsu.no'
  end

  def contact_email=(value)
    logger.info "member(#{id}).contact_email=(#{value.inspect})"
    previous_contact_email = contact_email
    logger.info "previous_contact_email: #{previous_contact_email.inspect}"
    return if value == previous_contact_email
    new_contact_user = User.find_by(email: value) if value.present?
    logger.info "new_contact_user: #{new_contact_user.inspect}"
    if new_contact_user&.== user
      logger.info 'clear contact user id'
      self.contact_user_id = nil
    elsif new_contact_user
      logger.info 'set new contact user'
      self.contact_user = new_contact_user
    elsif billing_user&.== contact_user
      logger.info 'Update billing user email'
      billing_user.email = value
    elsif user&.guardian_1&.== contact_user
      logger.info 'Update guardian 1 user email'
      user.guardian_1.email = value
    elsif user&.guardian_2&.== contact_user
      logger.info 'Update guardian 2 user email'
      user.guardian_2.email = value
    elsif user
      logger.info 'Update user email'
      user.email = value
    else
      logger.info 'Create a new user'
      build_user email: value
    end
  end

  def parent_1_or_billing_name
    user.guardian_1&.name || billing_user&.name
  end

  def parent_1_or_billing_name=(value)
    u = user.guardian_1 || billing_user
    if u.nil? && value.present?
      u = user.guardianships.build(index: 1, guardian_user: User.new)&.guardian_user
    end
    u.name = value if u
  end

  def invoice_email
    billing_email || email
  end

  def billing_email
    billing_user&.email
  end

  def related_users
    users = { member: user }
    user.guardianships.each { |gs| users[gs.relationship] = gs.guardian_user }
    users[:billing] = billing_user if billing_user
    users
  end

  def emails
    emails = []
    emails += user&.emails
    emails << billing_user&.email
    emails.compact.uniq
  end

  def phones
    phones = []
    phones << phone_home
    # phones << phone_mobile
    # phones << phone_parent
    phones << phone_work
    phones += user.phones
    phones << billing_phone_home
    phones << billing_user&.phone
    phones.reject(&:blank?).uniq
  end

  def title(date = Date.current)
    current_rank = current_rank(MartialArt.find_by(name: 'Kei Wa Ryu'), date)
    current_rank&.name =~ /dan/ ? 'Sensei' : 'Sempai'
  end

  def admin?
    elections.current.any? || appointments.current.any?
  end

  def instructor?(date = Date.current)
    instructor || group_instructor?(date)
  end

  def group_instructor?(date = Date.current)
    group_instructors.active(date).any?
  end

  def technical_committy?
    current_rank && (current_rank >= Rank.kwr.find_by(name: '1. kyu')) && active?
  end

  def to_s
    name
  end
end
