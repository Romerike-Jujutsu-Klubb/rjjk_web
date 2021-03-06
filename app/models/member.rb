# frozen_string_literal: true

# TODO(uwe): Rename to Membership
class Member < ApplicationRecord
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'
  SEARCH_FIELDS = %i[comment phone_home phone_work].freeze

  has_paper_trail

  belongs_to :user, -> { with_deleted }, inverse_of: :memberships

  has_one :current_election, -> { current }, class_name: :Election, inverse_of: :member
  has_one :next_graduate, -> do
    includes(:graduation).where('graduations.held_on >= ?', Date.current).order('graduations.held_on')
  end, class_name: :Graduate, inverse_of: :member

  has_many :active_group_instructors, -> { active }, class_name: :GroupInstructor, inverse_of: :member
  has_many :appointments, dependent: :destroy
  has_many :censors, dependent: :destroy
  has_many :correspondences, dependent: :destroy
  has_many :elections, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :group_instructors, dependent: :destroy
  has_many :passed_graduates, -> { where graduates: { passed: true } }, class_name: 'Graduate',
      inverse_of: :member
  has_many :survey_requests, dependent: :destroy

  has_many :ranks, through: :passed_graduates

  accepts_nested_attributes_for :user

  scope :active, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.current
    to_date ||= from_date
    references(:members)
        .where('members.joined_on <= ? AND (members.left_on IS NULL OR members.left_on >= ?)',
            to_date, from_date)
  end
  scope :search, ->(query) do
    where(SEARCH_FIELDS.map { |c| "UPPER(#{c}::text) ~ :query" }.join(' OR '),
        query: query.upcase.split(/\s+/).join('|'))
  end
  scope :with_user, -> { includes(:user).references(:users) }

  NILLABLE_FIELDS = %i[account_no comment phone_home phone_work].freeze
  before_validation do
    NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? }
  end

  validates :instructor, inclusion: { in: [true, false] }
  validates :joined_on, presence: true
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
    active(date).where(<<~SQL.squish).order(:id).includes(includes)
      instructor = true OR id IN (SELECT member_id FROM group_instructors GROUP BY member_id)
    SQL
  end

  delegate :age, :attendances, :attendances_since_graduation, :birthdate, :email, :first_name, :groups,
      :last_name, :male, :name, :recent_attendances,
      to: :user, allow_nil: true

  def gmaps4rails_infowindow
    html = +''
    if image?
      html << "<img src='/members/thumbnail/#{id}.#{image.format}' width='128' " \
          "style='float: left; margin-right: 1em'>"
    end
    html << name
    html
  end

  def current_graduate(martial_art_id, date = Date.current)
    grs = if graduates.loaded?
            graduates.sort_by { |g| -g.rank.position }
          else
            graduates.includes(:graduation, :rank).order('ranks.position DESC')
          end
    grs.find do |g|
      g.passed? && g.graduation.held_on < date &&
          (!martial_art_id || g.rank.martial_art_id == martial_art_id)
    end
  end

  def current_rank(martial_art_id = nil, date = Date.current)
    current_graduate(martial_art_id, date)&.rank || Rank::UNRANKED
  end

  def current_rank_date(martial_art_id = nil, date = Date.current)
    graduate = current_graduate(martial_art_id, date)
    graduate&.graduation&.held_on || joined_on
  end

  def current_rank_age(martial_art_id, to_date)
    date = current_rank_date(martial_art_id, to_date)
    days = (to_date - date).to_i
    years = (to_date - date).to_i / 365
    months = (days - (years * 365)) / 30
    [years.positive? ? "#{years} år" : nil, years.zero? || months.positive? ? "#{months} mnd" : nil]
        .compact.join(' ')
  end

  def next_rank(graduation = Graduation.new(held_on: Date.current, group: groups.max_by(&:from_age)))
    age = self.age(graduation.held_on)
    ma = graduation.group&.martial_art ||
        MartialArt.includes(curriculum_groups: :ranks).find_by(name: 'Kei Wa Ryu')
    current_rank = current_rank(ma.id, graduation.held_on)
    future_ranks = future_ranks(graduation.held_on, ma)
    all_ranks = ma.curriculum_groups.flat_map(&:ranks).sort_by do |r|
      [r.curriculum_group_id == graduation.group&.curriculum_group_id ? 0 : 1, r.position]
    end
    available_ranks = all_ranks - future_ranks
    available_ranks.select! { |r| r.position > current_rank.position } if current_rank
    next_rank = available_ranks.find do |r|
      (r.curriculum_group.from_age..r.curriculum_group.to_age).cover?(age) &&
          age >= r.minimum_age &&
          user.attendances_since_graduation(graduation.held_on, r.curriculum_group.practice_groups)
              .size > r.minimum_attendances
    end
    next_rank ||= available_ranks.find do |r|
      (age.nil? || age >= r.curriculum_group.from_age) &&
          (age.nil? || age >= r.minimum_age) &&
          user.attendances_since_graduation(graduation.held_on, r.curriculum_group.practice_groups)
              .size > r.minimum_attendances
    end
    if age
      next_rank ||= available_ranks.find do |r|
        (r.curriculum_group.from_age..r.curriculum_group.to_age).cover?(age) && age >= r.minimum_age
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

  def active?(date = Date.current)
    (date >= joined_on && (left_on.nil? || date <= left_on)) && !passive?(date)
  end

  def passive?(date = Date.current)
    passive_on && date >= passive_on
  end

  def active_and_attending?(date = Date.current, group = nil)
    active?(date) && user.attending?(date, group)
  end

  def passive_or_absent?(date = Date.current, group = nil)
    passive?(date) || user.absent?(date, group)
  end

  def paying?
    active?
  end

  def senior?
    birthdate && (age >= JUNIOR_AGE_LIMIT)
  end

  def left?(date = Date.current)
    left_on&.< date
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
    [phone_home, phone_work, *user.phones, billing_phone_home].reject(&:blank?).uniq
  end

  def title(date = Date.current)
    current_rank = current_rank(MartialArt::KWR_ID, date)
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
    current_rank&.>=(Rank.kwr.find_by(name: '1. kyu')) && active_and_attending?
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
    user.contact_users.any? do |other_user|
      next if other_user == user

      older_member?(other_user) || other_user.depending_users.any? { |u| older_member?(u) }
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

    calculated_discount[0]
  end

  def calculated_discount
    if honorary?
      [100, :honorary_member]
    elsif passive_on
      [100, :passive]
    elsif current_election&.role&.years_on_the_board
      [100, :on_the_board]
    elsif current_election
      [100, :elected]
    elsif active_group_instructors.size >= 2
      [100, :instructor]
    elsif active_group_instructors.size == 1
      [50, :half_instructor]
    elsif instructor?
      [50, :permanent_instructor]
    else
      [nil, nil]
    end
  end

  private

  def older_member?(other_user)
    other_user.id != user_id && other_user.birthdate && other_user.member&.active? &&
        (other_user.birthdate < user.birthdate ||
            (other_user.birthdate == user.birthdate && other_user.id < user_id))
  end
end
