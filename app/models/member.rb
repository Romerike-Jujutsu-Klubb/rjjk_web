# frozen_string_literal: true

# TODO(uwe): Rename to Membership
class Member < ApplicationRecord
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'
  SEARCH_FIELDS =
      %i[comment nkf_members.medlemsnummer phone_home phone_work].freeze

  has_paper_trail

  belongs_to :user, -> { with_deleted }, inverse_of: :member

  has_one :current_election, -> { current }, class_name: :Election
  has_one :last_member_image, -> { order :created_at }, class_name: :MemberImage
  has_one :image, through: :last_member_image
  has_one :next_graduate, -> do
    includes(:graduation).where('graduations.held_on >= ?', Date.current)
        .order('graduations.held_on')
  end, class_name: :Graduate
  has_one :nkf_member, dependent: :nullify

  has_many :active_group_instructors, -> { active }, class_name: :GroupInstructor, inverse_of: :member
  has_many :appointments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :censors, dependent: :destroy
  has_many :correspondences, dependent: :destroy
  has_many :elections, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :group_instructors, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :member_images, dependent: :destroy
  has_many :passed_graduates, -> { where graduates: { passed: true } }, class_name: 'Graduate'
  has_many :recent_attendances, -> { merge(Attendance.from_date(92.days.ago).to_date(31.days.from_now)) },
      class_name: :Attendance
  has_many :signatures, dependent: :destroy
  has_many :survey_requests, dependent: :destroy

  has_many :groups, through: :group_memberships
  has_many :ranks, through: :passed_graduates

  accepts_nested_attributes_for :user

  scope :absent_since, ->(from_date = nil, to_date = nil) do
    where.not(id: attending_since(from_date, to_date))
  end
  scope :active, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.current
    to_date ||= from_date
    references(:members)
        .where('members.joined_on <= ? AND members.left_on IS NULL OR members.left_on >= ?',
            to_date, from_date)
  end
  scope :attending_since, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.current
    to_date ||= Date.current
    merge(Attendance.from_date(from_date).to_date(to_date))
  end
  scope :search, ->(query) do
    includes(:nkf_member).references(:nkf_members)
        .where(SEARCH_FIELDS.map { |c| "UPPER(#{c}::text) ~ :query" }.join(' OR '),
            query: UnicodeUtils.upcase(query).split(/\s+/).join('|'))
  end
  scope :with_user, -> { includes(:user).references(:users) }

  NILLABLE_FIELDS = %i[account_no comment phone_home phone_work].freeze
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

  def self.instructors(date = Date.current, includes: [])
    active(date).where(<<~SQL).order(:id).includes(includes)
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

  def current_rank(martial_art = nil, date = Date.current)
    current_graduate(martial_art, date)&.rank || Rank::UNRANKED
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
    all_ranks = ma.ranks.to_a.sort_by { |r| [r.group_id == graduation.group_id ? 0 : 1, r.position] }
    available_ranks = all_ranks - future_ranks
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

  def passive?(date = Date.current)
    passive_on && date >= passive_on
  end

  def attending?(date = Date.current, group = nil)
    !absent?(date, group)
  end

  def absent?(date = Date.current, group = nil)
    return false if date <= joined_on + 2.months

    start_date = date - 92
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

  def active_and_attending?(date = Date.current, group = nil)
    active?(date) && attending?(date, group)
  end

  def passive_or_absent?(date = Date.current, group = nil)
    passive?(date) || absent?(date, group)
  end

  def paying?
    active? && nkf_member&.kontraktsbelop.to_i > 0
  end

  def senior?
    birthdate && (age >= JUNIOR_AGE_LIMIT)
  end

  def left?(date = Date.current)
    left_on&.< date
  end

  def nkf_fee_amount
    if senior?
      (nkf_fee? ? (279.0 / 12).ceil : 0)
    else
      (nkf_fee? ? (155.0 / 12).ceil : 0)
    end
  end

  # FIXME(uwe): Use PriceAgeGroup?
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
    /dan/.match?(current_rank&.name) ? 'Sensei' : 'Sempai'
  end

  def admin?
    elections.current.any? || appointments.current.any?
  end

  def instructor?
    instructor || group_instructor?
  end

  def group_instructor?
    active_group_instructors.any?
  end

  def instruction_groups
    scheduled = group_instructors.active.map(&:group_semester).map(&:group).uniq
    attended = attendances
        .joins(practice: :group_schedule)
        .after(2.months.ago)
        .where(status: [Attendance::Status::INSTRUCTOR, Attendance::Status::ASSISTANT])
        .where.not('group_schedules.group_id' => scheduled.map(&:id))
        .map(&:practice).map(&:group_schedule).map(&:group).uniq
    (scheduled + attended).sort_by(&:from_age)
  end

  def technical_committy?
    current_rank && (current_rank >= Rank.kwr.find_by(name: '1. kyu')) && active_and_attending?
  end

  def honorary?
    honorary_on
  end

  def to_s
    name
  end

  def to_graduate(graduation)
    g = Graduate.new graduation: graduation, member: self
    g.populate_defaults!
    g
  end

  def category
    if honorary?
      'Æresmedlem'
    elsif (pag = PriceAgeGroup.find_by(':age >= from_age AND :age <= to_age', age: age))
      pag.name
    else
      'Ukjent'
    end
  end

  def contract
    base_contract =
        if category == 'Voksen'
          groups.max_by(&:monthly_fee)&.contract || category
        else
          category
        end
    if older_family?
      "#{base_contract} - familie"
    else
      base_contract
    end
  end

  def older_family?
    user.contact_users.any? do |u|
      next if u == user

      older_member?(u) || u.depending_users.any?(&method(:older_member?))
    end
  end

  def monthly_fee
    return 0 if honorary?

    group_fee = groups.map(&:monthly_fee).compact.max
    age_fee = PriceAgeGroup.find_by('from_age <= :age AND to_age >= :age', age: age)&.monthly_fee
    group_fee = age_fee if age_fee && (group_fee.nil? || age_fee < group_fee)
    return nil unless group_fee

    family_fee =
        if older_family?
          group_fee - 50
        else
          group_fee
        end
    if discount
      ((family_fee * (100 - discount)) / 100.0).round
    else
      family_fee
    end
  end

  def discount
    return discount_override if discount_override

    if honorary?
      nil
    # elsif passive_on
    #   100
    elsif current_election
      100
    elsif active_group_instructors.count == 1
      50
    elsif active_group_instructors.count >= 2
      100
    elsif instructor?
      50
    end
  end

  private

  def older_member?(other_user)
    other_user.id != user_id && other_user.birthdate && other_user.member&.active? &&
        (other_user.birthdate < user.birthdate ||
            (other_user.birthdate == user.birthdate && other_user.id < user_id))
  end
end
