class Member < ActiveRecord::Base
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = 'left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)'

  acts_as_gmappable check_process: :prevent_geocoding, validation: false

  def prevent_geocoding
    address.blank? || (latitude.present? && longitude.present?)
  end

  belongs_to :image, dependent: :destroy
  belongs_to :user, dependent: :destroy
  has_one :next_graduate,
  -> { includes(:graduation).where('graduations.held_on >= ?', Date.today).order('graduations.held_on') },
      class_name: :Graduate
  has_one :nkf_member, dependent: :nullify
  has_many :appointments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :censors, dependent: :destroy
  has_many :correspondences, dependent: :destroy
  has_many :elections, dependent: :destroy
  has_many :graduates, dependent: :destroy
  has_many :group_instructors, dependent: :destroy

  # FIXME(uwe):  Use Attendance scopes instead?
  has_many :last_6_months_attendances, -> do
    from_date = 6.months.ago.to_date
    to_date = Time.zone.today
    includes(practice: :group_schedule).references(:group_schedules)
        .where('year > ? OR (year = ? AND week > ?) OR (year = ? AND week = ? AND group_schedules.weekday > ?)',
            from_date.year, from_date.year, from_date.cweek, from_date.year, from_date.cweek, from_date.cwday)
        .where('year < ? OR (year = ? AND week < ?) OR (year = ? AND week = ? AND group_schedules.weekday <= ?)',
            to_date.year, to_date.year, to_date.cweek, to_date.year, to_date.cweek, to_date.cwday)
  end,
      class_name: Attendance
  # EMXIF

  has_many :passed_graduates, -> { where graduates: { passed: true } },
      class_name: 'Graduate'
  has_many :ranks, through: :passed_graduates

  # FIXME(uwe):  Use Attendance scopes instead?
  has_many :recent_attendances, -> do
    from_date = Time.zone.today - 92
    to_date = Time.zone.today + 31
    includes(practice: :group_schedule).references(:group_schedules)
        .where('year > ? OR (year = ? AND week > ?) OR (year = ? AND week = ? AND group_schedules.weekday > ?)',
            from_date.year, from_date.year, from_date.cweek, from_date.year, from_date.cweek, from_date.cwday)
        .where('year < ? OR (year = ? AND week < ?) OR (year = ? AND week = ? AND group_schedules.weekday <= ?)',
            to_date.year, to_date.year, to_date.cweek, to_date.year, to_date.cweek, to_date.cwday)
  end,
      class_name: Attendance
  # EMXIF

  has_many :signatures, dependent: :destroy
  has_many :survey_requests, dependent: :destroy
  has_and_belongs_to_many :groups

  scope :without_image, -> { select(column_names - ['image_id']) }
  scope :active, ->(from_date = nil, to_date = nil) do
    from_date ||= Date.today
    to_date ||= from_date
    where('joined_on <= ? AND left_on IS NULL OR left_on >= ?', to_date, from_date)
  end
  SEARCH_FIELDS = [
      :billing_email, :email, :first_name, :last_name, :parent_email,
      :parent_name, :phone_home, :phone_mobile, :phone_parent, :phone_work]
  scope :search, ->(query) {
    where(SEARCH_FIELDS.map { |c| "UPPER(#{c}) ~ ?" }
            .join(' OR '), *([UnicodeUtils.upcase(query).split(/\s+/).join('|')] * SEARCH_FIELDS.size))
        .order(:first_name, :last_name)
  }

  NILLABLE_FIELDS = [:parent_name, :phone_home, :phone_mobile, :phone_work]
  before_validation { NILLABLE_FIELDS.each { |f| self[f] = nil if self[f].blank? } }

  # validates_presence_of :address, :cms_contract_id
  validates_length_of :billing_postal_code, is: 4, if: Proc.new { |m| m.billing_postal_code && !m.billing_postal_code.empty? }
  validates_presence_of :birthdate, :joined_on
  validates_uniqueness_of :cms_contract_id, if: :cms_contract_id
  validates_length_of :email, maximum: 128
  validates_presence_of :first_name, :last_name
  validates_inclusion_of :instructor, in: [true, false]
  validates_inclusion_of :male, in: [true, false]
  validates_inclusion_of :nkf_fee, in: [true, false]
  validates_inclusion_of :payment_problem, in: [true, false]
  # validates_presence_of :postal_code
  validates_length_of :postal_code, is: 4, allow_blank: true
  validates_uniqueness_of :rfid, if: Proc.new { |r| r.rfid && !r.rfid.empty? }
  validates_presence_of :user, :user_id, unless: :left_on

  def self.paginate_active(page)
    active.order(:first_name, :last_name).paginate(page: page, per_page: MEMBERS_PER_PAGE)
  end

  def self.instructors(date = Date.today)
    active(date)
        .where('instructor = true OR id IN (SELECT member_id FROM group_instructors GROUP BY member_id)')
        .order('first_name, last_name').to_a
  end

  def self.create_corresponding_user!(attrs)
    attrs.symbolize_keys!
    email = attrs[:email]
    first_name = attrs[:first_name]
    last_name = attrs[:last_name]
    passwd = (0..4).map { [*((0..9).to_a + ('a'..'z').to_a)][rand(36)] }.join

    # Full name and email
    full_email = make_usable_full_email(email, first_name, last_name)
    full_email_with_birthyear = make_usable_full_email(email, first_name, last_name, attrs[:birthdate].to_s[0..3])
    full_email_with_birthdate = make_usable_full_email(email, first_name, last_name, attrs[:birthdate].to_s)
    full_email_with_join_year = make_usable_full_email(email, first_name, last_name, attrs[:joined_on].to_s[0..3])

    potential_emails = [email, full_email, full_email_with_birthyear,
        full_email_with_birthdate, full_email_with_join_year]
    blocking_users = []
    potential_emails.compact.each do |potential_email|
      existing_user = User.where('(login = ? OR email = ?) AND NOT EXISTS (SELECT id FROM members WHERE user_id = users.id)',
          potential_email, potential_email).first
      return existing_user if existing_user

      if (user_with_email = User.where('login = ? OR email = ?', *([potential_email] * 2)).first)
        logger.info "A user with this email already exists: #{user_with_email}"
        blocking_users << user_with_email
        next
      end

      new_user = User.new(
          login: potential_email, first_name: first_name, last_name: last_name,
          email: potential_email, password: passwd, password_confirmation: passwd,
      )
      new_user.password_needs_confirmation = true
      new_user.save!

      return new_user
    end
    raise "Unable to create user for member #{attrs}\npotential phones: #{potential_emails}\nattributes: #{attrs}\nblocking users: #{blocking_users.inspect}"
  end

  def self.make_usable_full_email(email, first_name, last_name, birthdate = nil)
    birth_suffix = (" (#{birthdate})" if birthdate)
    full_email = %("#{first_name} #{last_name}#{birth_suffix}" <#{email}>)
    max_length = 64

    # First and last names only
    if full_email.size > max_length
      logger.debug "Full email too long: #{full_email}"
      full_email = %("#{first_name.split(/\s+/).first} #{last_name.split(/\s+/).last}#{birth_suffix}" <#{email}>)
    end

    # Squeezed name and full email
    if full_email.size > max_length
      logger.debug "Full email too long: #{full_email}"
      max_name_size = max_length - email.size - 5
      (cut_name = "#{first_name} #{last_name}#{birth_suffix}")[(max_name_size / 2) - 2..(-max_name_size / 2)]
      full_email = %("#{cut_name}" <#{email}>)
    end

    # Fallback to non-valid email...
    if full_email.size > max_length
      logger.debug "Full email too long: #{full_email}"
      (full_email = %(#{first_name} #{last_name}#{birth_suffix} <#{email}>))[(max_length / 2) - 2..(-max_length / 2)]
    end
    full_email
  end

  # describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  def gmaps4rails_address
    "#{address}, #{postal_code}, Norway"
  end

  def gmaps4rails_infowindow
    html = ''
    html << "<img src='/members/thumbnail/#{id}.#{image.format}' width='128' style='float: left; margin-right: 1em'>" if image?
    html << name
    html
  end

  def create_corresponding_user!
    new_user = self.class.create_corresponding_user!(attributes)
    update! user_id: new_user.id
  end

  def current_graduate(martial_art, date = Date.today)
    graduates.sort_by { |g| -g.rank.position }
        .find { |g| g.passed? && g.graduation.held_on < date && (martial_art.nil? || g.rank.martial_art_id == martial_art.id) }
  end

  def attendances_since_graduation(before_date = Date.today, group = nil, includes: nil)
    groups = group ? [group] : Group.includes(:martial_art).to_a
    queries = groups.map do |g|
      ats = attendances
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

  def current_rank(martial_art = nil, date = Date.today)
    current_graduate(martial_art, date).try(:rank)
  end

  def current_rank_date(martial_art = nil, date = Date.today)
    graduate = current_graduate(martial_art, date)
    graduate && graduate.graduation.held_on || joined_on
  end

  def current_rank_age(martial_art, to_date)
    date = current_rank_date(martial_art, to_date)
    days = (to_date - date).to_i
    years = (to_date - date).to_i / 365
    months = (days - (years * 365)) / 30
    [years.positive? ? "#{years} år" : nil, years.zero? || months.positive? ? "#{months} mnd" : nil].compact.join(' ')
  end

  def next_rank(graduation = Graduation.new(held_on: Date.today, group: groups.sort_by(&:from_age).last))
    age = self.age(graduation.held_on)
    ma = graduation.group.try(:martial_art) || MartialArt.includes(:ranks).find_by_name('Kei Wa Ryu')
    current_rank = current_rank(ma, graduation.held_on)
    ranks = ma.ranks.to_a
    if current_rank
      next_rank = ranks.find { |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            (r.group.from_age..r.group.to_age).cover?(age) &&
            (age.nil? || age >= r.minimum_age) &&
            attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
      }
      next_rank ||= ranks.find { |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            (age.nil? || age >= r.group.from_age) &&
            (age.nil? || age >= r.minimum_age) &&
            attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
      }
      next_rank ||= ranks.find { |r|
        !future_ranks(graduation.held_on, ma).include?(r) &&
            r.position > current_rank.position &&
            (r.group.from_age..r.group.to_age).cover?(age) &&
            (age.nil? || age >= r.minimum_age)
      }
      next_rank ||= ranks.find { |r| r.position > current_rank.position }
    end
    next_rank ||= ranks.find { |r|
      !future_ranks(graduation.held_on, ma).include?(r) &&
          (r.group.from_age..r.group.to_age).cover?(age) &&
          (age.nil? || age >= r.minimum_age) &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    }
    next_rank ||= ranks.find { |r|
      !future_ranks(graduation.held_on, ma).include?(r) &&
          (age.nil? || age >= r.minimum_age) &&
          attendances_since_graduation(graduation.held_on, r.group).size > r.minimum_attendances
    }
    next_rank ||= ranks.find { |r| age.nil? || (age >= r.minimum_age && (r.group.from_age..r.group.to_age).cover?(age)) }
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

  def active?(date = Date.today)
    !passive?(date)
  end

  def passive?(date = Date.today, group = nil)
    return true if nkf_member.try(:medlemsstatus) == 'P'
    return false if joined_on >= date - 2.months
    start_date = date - 92
    end_date = date + 31
    if date == Date.today && recent_attendances.loaded?
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

  def age(date = Date.today)
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

  def name
    "#{first_name} #{last_name}"
  end

  def guardians
    guardians = {}
    if parent_name
      guardians[1] = {
          name: parent_name,
          email: parent_email,
          phone: phone_parent,
      }
    end
    if parent_2_name
      guardians[2] = {
          name: parent_2_name,
          email: billing_email,
          phone: parent_2_mobile,
      }
    end
    guardians
  end

  def image_file=(file)
    return if file.blank?
    create_image! user_id: user_id, name: file.original_filename,
        content_type: file.content_type, content_data: file.read
  end

  def image?
    !!image_id
  end

  def thumbnail(x = 120, y = 160)
    return unless image?
    magick_image = Magick::Image.from_blob(Image.with_image.find(image_id).content_data).first
    magick_image.crop_resized(x, y).to_blob
  end

  def cms_member
    CmsMember.find_by_cms_contract_id(cms_contract_id)
  end

  def invoice_email
    billing_email || email
  end

  def emails
    emails = []
    emails << %("#{name}" <#{email}>) if email
    if billing_email
      emails << (parent_name ? %("#{parent_name}" <#{billing_email}>) : billing_email)
    end
    if parent_email
      emails << (parent_2_name ? %("#{parent_2_name}" <#{parent_email}>) : parent_email)
    end
    emails.uniq
  end

  def phones
    phones = []
    phones << phone_home
    phones << phone_mobile
    phones << phone_parent
    phones << phone_work
    phones << billing_phone_home
    phones << billing_phone_mobile
    phones.reject(&:blank?).uniq
  end

  def title(date = Date.today)
    current_rank = current_rank(MartialArt.find_by_name('Kei Wa Ryu'), date)
    current_rank && current_rank.name =~ /dan/ ? 'Sensei' : 'Sempai'
  end

  def admin?
    elections.current.any? || appointments.current.any?
  end

  def instructor?(date = Date.today)
    instructor || group_instructor?(date)
  end

  def group_instructor?(date = Date.today)
    group_instructors.active(date).any?
  end

  def technical_committy?
    current_rank && (current_rank >= Rank.kwr.where(name: '1. kyu').first) && active?
  end
end
