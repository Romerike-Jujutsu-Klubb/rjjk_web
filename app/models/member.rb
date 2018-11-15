# frozen_string_literal: true

# TODO(uwe): Rename to Membership
class Member < ApplicationRecord
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'
  SEARCH_FIELDS =
      %i[comment nkf_members.medlemsnummer phone_home phone_work].freeze

  belongs_to :user, -> { with_deleted }, inverse_of: :member

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

  scope :active, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.current
    to_date ||= from_date
    references(:members)
        .where('members.joined_on <= ? AND members.left_on IS NULL OR members.left_on >= ?',
            to_date, from_date)
  end
  scope :search, ->(query) do
    includes(:nkf_member).references(:nkf_members)
        .where(SEARCH_FIELDS.map { |c| "UPPER(#{c}::text) ~ :query" }.join(' OR '),
            query: UnicodeUtils.upcase(query).split(/\s+/).join('|'))
  end
  scope :with_user, -> { includes(:user).references(:users) }

  NILLABLE_FIELDS = %i[phone_home phone_work].freeze
  before_validation do
    NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? }
  end

  validates :instructor, inclusion: { in: [true, false] }
  validates :joined_on, presence: true
  validates :nkf_fee, inclusion: { in: [true, false] }
  validates :payment_problem, inclusion: { in: [true, false] }
  validates :user, presence: true

  validate do
    if user.first_name.blank?
      errors.add :base, 'The member is missing a first name'
      user.errors.add :first_name, I18n.t('activerecord.errors.messages.blank')
    end
    if user.last_name.blank?
      errors.add :base, 'The member is missing a last name'
      user.errors.add :last_name, I18n.t('activerecord.errors.messages.blank')
    end
  end

  def self.instructors(date = Date.current)
    active(date).where(<<~SQL).order(:id)
      instructor = true OR id IN (SELECT member_id FROM group_instructors GROUP BY member_id)
    SQL
  end

  delegate :age, :birthdate, :email, :first_name, :last_name, :male, :name, to: :user, allow_nil: true

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
    grs = if graduates.loaded?
            graduates.sort_by { |g| -g.rank.position }
          else
            graduates.includes(:graduation, :rank).order('ranks.position DESC')
          end
    grs.find do |g|
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
        ats = ats.after(c.graduation.held_on)
      end
      ats = ats.until_date(before_date)
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

  def next_rank(graduation = Graduation.new(held_on: Date.current, group: groups.max_by(&:from_age)))
    age = self.age(graduation.held_on)
    ma = graduation.group.try(:martial_art) || MartialArt.includes(:ranks).find_by(name: 'Kei Wa Ryu')
    current_rank = current_rank(ma, graduation.held_on)
    future_ranks = future_ranks(graduation.held_on, ma)
    available_ranks = ma.ranks.to_a - future_ranks
    available_ranks.select! { |r| r.position > current_rank.position } if current_rank
    next_rank = available_ranks.find do |r|
      (r.group.from_age..r.group.to_age).cover?(age) &&
          age >= r.minimum_age &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    end
    next_rank ||= available_ranks.find do |r|
      (age.nil? || age >= r.group.from_age) &&
          (age.nil? || age >= r.minimum_age) &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    end
    if age
      next_rank ||= available_ranks.find do |r|
        (r.group.from_age..r.group.to_age).cover?(age) && age >= r.minimum_age
      end
      next_rank ||= available_ranks.find { |r| age >= r.minimum_age }
    end
    next_rank ||= available_ranks.first
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
    return true if passive_on && date >= passive_on
    return false if date <= joined_on + 2.months

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
      query = query.after(start_date)
      query = query.until_date(end_date)
      query.empty?
    end
  end

  def paying?
    nkf_member&.kontraktsbelop.to_i > 0
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

  delegate :guardian_1, :guardian_2, :guardians, to: :user

  def billing
    user.billing_user
  end
  # EMXIF

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

  # FIXME(uwe): Limit to Y-axis as well
  def thumbnail(x = 120, _y = 160)
    return unless image?

    magick_image = MiniMagick::Image.read(image.content_data_io)
    ratio = x.to_f / magick_image.width
    magick_image.resize("#{x}x#{(magick_image.height * ratio).round}")
    magick_image.to_blob
  end

  def invoice_email
    billing_email || email
  end

  def billing_email
    user.billing_user&.email
  end

  def related_users
    users = { user: user }
    users[:guardian_1] = user.guardian_1 if user.guardian_1
    users[:guardian_2] = user.guardian_2 if user.guardian_2
    users[:billing] = user.billing_user if user.billing_user
    users
  end

  delegate :emails, to: :user

  def phones
    phones = []
    phones << phone_home
    phones << phone_work
    phones += user.phones
    phones << billing_phone_home
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
