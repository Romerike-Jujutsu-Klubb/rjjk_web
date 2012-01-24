class Member < ActiveRecord::Base
  JUNIOR_AGE_LIMIT = 15
  ASPIRANT_AGE_LIMIT = 10
  MEMBERS_PER_PAGE = 30
  ACTIVE_CONDITIONS = "left_on IS NULL or left_on > DATE(CURRENT_TIMESTAMP)"

  scope :active, lambda { |date| {:conditions => ['left_on IS NULL OR left_on > ?', date]} }

  has_many :graduates
  has_many :attendances
  has_and_belongs_to_many :groups
  has_one :nkf_member

  # validates_presence_of :address, :cms_contract_id
  validates_length_of :billing_postal_code, :is => 4, :if => Proc.new { |m| m.billing_postal_code && !m.billing_postal_code.empty? }
  # validates_presence_of :birthdate, :join_on
  validates_uniqueness_of :cms_contract_id, :if => :cms_contract_id
  validates_presence_of :first_name, :last_name
  validates_inclusion_of :instructor, :in => [true, false]
  validates_inclusion_of :male, :in => [true, false]
  validates_inclusion_of :nkf_fee, :in => [true, false]
  validates_inclusion_of :payment_problem, :in => [true, false]
  #validates_presence_of :postal_code
  validates_length_of :postal_code, :is => 4, :if => Proc.new { |m| m.postal_code && !m.postal_code.empty? }
  validates_uniqueness_of :rfid, :if => Proc.new { |r| r.rfid and not r.rfid.empty? }

  def self.find_active
    find(:all, :conditions => ACTIVE_CONDITIONS, :order => 'last_name, first_name')
  end

  def self.paginate_active(page)
    paginate :page => page, :per_page => MEMBERS_PER_PAGE, :conditions => ACTIVE_CONDITIONS, :order => 'first_name, last_name'
  end

  def self.count_active
    count :conditions => ACTIVE_CONDITIONS
  end

  def self.find_by_contents(query, options = {})
    search_fields = [:first_name, :last_name, :email]
    all({
            :conditions => [search_fields.map { |c| "UPPER(#{c}) LIKE ?" }.join(' OR '), *(["%#{query.upcase}%"] * search_fields.size)],
            :order => 'first_name, last_name',
        }.update(options))
  end

  def current_graduate(martial_art, date = Date.today)
    graduates.select { |g| g.graduation.held_on < date && (martial_art.nil? || g.rank.martial_art == martial_art) }.sort_by { |g| g.rank.position }.last
  end

  def current_rank(martial_art = nil, date = Date.today)
    current_graduate(martial_art, date).try(:rank)
  end

  def current_rank_date(martial_art = nil)
    graduate = self.current_graduate(martial_art)
    graduate && graduate.graduation.held_on || joined_on
  end

  def current_rank_age(martial_art = nil)
    date = current_rank_date
    days = (Date.today - date).to_i
    years = (Date.today - date).to_i / 365
    months = (days - (years * 365)) / 30
    "#{"#{years} år" if years > 0} #{"#{months} mnd" if years == 0 || months > 0}" # TODO: What about leap years etc?
  end

  def next_rank(graduation)
    age = self.age(graduation.held_on)
    ma = graduation.martial_art
    current_rank = current_rank(ma, graduation.held_on)
    if current_rank
      next_rank = ma.ranks.select { |r| !future_ranks(graduation).include?(r) && r.position > current_rank.position &&
          age >= r.minimum_age && (r.group.from_age..r.group.to_age).include?(age) }.first
      next_rank ||= Rank.find(:first, :conditions => ['martial_art_id = ? AND position = ?', ma, current_rank.position + 1])
    end
    next_rank ||= ma.ranks.select { |r| age >= r.minimum_age && (r.group.from_age..r.group.to_age).include?(age) }.first
    next_rank ||= ma.ranks.first
    next_rank
  end

  def future_graduates(graduation)
    graduates.select { |g| g.graduation.martial_art == graduation.martial_art && g.graduation.held_on > graduation.held_on }
  end

  def future_ranks(graduation)
    future_graduates(graduation).map(&:rank)
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
      "Senior"
    else
      "Junior"
    end
  end

  def gender
    if male
      "Mann"
    else
      "Kvinne"
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def image_file=(file)
    return if file == ""
    self.image = file.read
    self.image_name = file.original_filename
    self.image_content_type = file.content_type
  end

  def image_format
    image_name && image_name.split('.').last
  end

  def thumbnail(x = 120, y = 160)
    return unless self.image
    magick_image = Magick::Image.from_blob(self.image).first
    return magick_image.crop_resized(x, y).to_blob
  end

  def cms_member
    CmsMember.find_by_cms_contract_id(cms_contract_id)
  end

  def invoice_email
    nkf_member.epost_faktura.blank? ? email : nkf_member.epost_faktura
  end

end
